#!/usr/bin/env ruby

require "date"
require "pathname"
require "tmpdir"
require "uri"
require "yaml"

class ContentValidator
  FRONT_MATTER = /\A---\s*\n(?<yaml>.*?)\n---\s*\n/m
  ID_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
  POST_FILENAME = /\A(?<year>\d{4})-(?<month>\d{1,2})-(?<day>\d{1,2})-(?<slug>.+)\.(?:md|markdown|html)\z/
  URL_FIELDS = %w[source_url registration_url recording_url slides_url repository_url].freeze

  attr_reader :errors

  def initialize(root)
    @root = Pathname(root)
    @errors = []
    @slugs = {}
    @urls = { "/" => "pages/index.md" }
    @internal_links = []
    @types = load_controlled_data("types")
    @categories = load_controlled_data("categories")
    @levels = load_controlled_data("levels")
    @statuses = load_controlled_data("statuses")
    @event_modes = load_controlled_data("event_modes")
    @event_states = load_controlled_data("event_states")
    @archives = { "type" => {}, "category" => {} }
  end

  def run
    validate_controlled_data
    content_files.each { |path| validate_file(path) }
    validate_archive_coverage
    validate_navigation
    validate_discovery_config
    validate_internal_links
    validate_docs_adapter
    errors
  end

  private

  def load_controlled_data(name)
    path = @root.join("_data", "#{name}.yml")
    unless path.file?
      errors << "#{path.relative_path_from(@root)}: arquivo controlado ausente"
      return {}
    end

    data = YAML.safe_load(path.read, permitted_classes: [Date, Time], aliases: false)
    return data if data.is_a?(Hash)

    errors << "#{path.relative_path_from(@root)}: deve conter um mapa YAML"
    {}
  rescue Psych::SyntaxError => error
    errors << "#{path.relative_path_from(@root)}: YAML invalido (#{error.problem})"
    {}
  end

  def content_files
    [@root.join("_posts"), @root.join("pages")]
      .flat_map { |directory| directory.glob("**/*.{md,markdown,html}") }
      .sort
  end

  def validate_controlled_data
    {
      "types" => @types,
      "categories" => @categories,
      "levels" => @levels,
      "statuses" => @statuses,
      "event_modes" => @event_modes,
      "event_states" => @event_states
    }.each do |name, entries|
      entries.each do |id, config|
        errors << "_data/#{name}.yml: ID invalido '#{id}'" unless id.to_s.match?(ID_PATTERN)
        unless config.is_a?(Hash) && present?(config["label"])
          errors << "_data/#{name}.yml: '#{id}' precisa de label"
        end
      end
    end

    @types.each do |id, config|
      policy = config.is_a?(Hash) ? config["level"] : nil
      errors << "_data/types.yml: politica de level invalida para '#{id}'" unless %w[required optional forbidden].include?(policy)
      errors << "_data/types.yml: schema ausente para '#{id}'" unless present?(config["schema"])
      errors << "_data/types.yml: toc deve ser booleano para '#{id}'" unless [true, false].include?(config["toc"])
      errors << "_data/types.yml: description ausente para '#{id}'" unless present?(config["description"])
    end
    @categories.each do |id, config|
      errors << "_data/categories.yml: description ausente para '#{id}'" unless present?(config["description"])
    end
    @event_modes.each do |id, config|
      errors << "_data/event_modes.yml: schema ausente para '#{id}'" unless present?(config["schema"])
    end
  end

  def validate_file(path)
    relative = path.relative_path_from(@root)
    body = path.read
    match = body.match(FRONT_MATTER)
    return errors << "#{relative}: front matter ausente ou invalido" unless match

    data = YAML.safe_load(match[:yaml], permitted_classes: [Date, Time], aliases: false) || {}
    return errors << "#{relative}: front matter deve ser um mapa YAML" unless data.is_a?(Hash)

    if relative.to_s.start_with?("_posts/")
      validate_post(relative, path, data)
    else
      validate_page(relative, data)
    end
    validate_layout(relative, data["layout"] || (relative.to_s.start_with?("_posts/") ? "post" : nil))
    validate_front_matter_image(relative, data)
    validate_body_images(relative, body)
    collect_internal_links(relative, body)
  rescue Psych::SyntaxError => error
    errors << "#{relative}: YAML invalido (#{error.problem})"
  end

  def validate_post(relative, path, data)
    %w[type title summary category tags status].each do |field|
      errors << "#{relative}: campo obrigatorio '#{field}' ausente" unless present?(data[field])
    end
    %w[type title summary category status].each do |field|
      errors << "#{relative}: '#{field}' deve ser uma string" if data.key?(field) && !data[field].is_a?(String)
    end
    errors << "#{relative}: 'author' deve ser uma string" if data.key?("author") && !data["author"].is_a?(String)
    errors << "#{relative}: use apenas status; o campo published nao e permitido" if data.key?("published")

    type_config = @types[data["type"]]
    errors << "#{relative}: type invalido '#{data["type"]}'" unless type_config
    errors << "#{relative}: category invalida '#{data["category"]}'" unless @categories.key?(data["category"])
    errors << "#{relative}: status invalido '#{data["status"]}'" unless @statuses.key?(data["status"])
    validate_level(relative, data, type_config)
    validate_tags(relative, data["tags"])
    validate_post_identity(relative, path, data)
    validate_dates(relative, path, data)
    validate_type_fields(relative, data)
    validate_urls(relative, data)
  end

  def validate_page(relative, data)
    validate_unique_url(relative, data["permalink"]) if present?(data["permalink"])
    return unless data["layout"] == "archive"

    kind = data["archive_kind"]
    id = data["archive_id"]
    unless @archives.key?(kind)
      errors << "#{relative}: archive_kind invalido '#{kind}'"
      return
    end
    source = kind == "type" ? @types : @categories
    errors << "#{relative}: archive_id invalido '#{id}' para #{kind}" unless source.key?(id)
    register_unique(@archives[kind], id, relative, "arquivo #{kind}") if present?(id)
    expected_url = "/conteudo/#{kind == "type" ? "tipos" : "categorias"}/#{id}/"
    errors << "#{relative}: permalink esperado #{expected_url}" unless data["permalink"] == expected_url
  end

  def validate_archive_coverage
    { "type" => @types, "category" => @categories }.each do |kind, source|
      (source.keys - @archives[kind].keys).each do |id|
        errors << "pages/archives: arquivo ausente para #{kind} '#{id}'"
      end
    end
  end

  def validate_navigation
    path = @root.join("_data", "navigation.yml")
    return errors << "_data/navigation.yml: arquivo ausente" unless path.file?

    entries = YAML.safe_load(path.read, aliases: false)
    unless entries.is_a?(Array) && !entries.empty?
      errors << "_data/navigation.yml: deve conter uma lista nao vazia"
      return
    end
    seen_urls = []
    entries.each_with_index do |entry, index|
      unless entry.is_a?(Hash)
        errors << "_data/navigation.yml: item #{index + 1} deve ser um mapa"
        next
      end
      %w[label aria_label url icon].each do |field|
        errors << "_data/navigation.yml: item #{index + 1} sem '#{field}'" unless present?(entry[field])
      end
      url = entry["url"].to_s
      errors << "_data/navigation.yml: URL interna invalida '#{url}'" unless url.start_with?("/")
      errors << "_data/navigation.yml: URL duplicada '#{url}'" if seen_urls.include?(url)
      seen_urls << url
      clean = normalize_url(url)
      errors << "_data/navigation.yml: destino inexistente '#{url}'" unless @urls.key?(clean)
    end
  rescue Psych::SyntaxError => error
    errors << "_data/navigation.yml: YAML invalido (#{error.problem})"
  end

  def validate_discovery_config
    config_path = @root.join("_config.yml")
    config = YAML.safe_load(config_path.read, permitted_classes: [Date, Time], aliases: false) || {}
    errors << "_config.yml: plugin jekyll-feed ausente" unless Array(config["plugins"]).include?("jekyll-feed")
    errors << "_config.yml: feed.path deve ser feed.xml" unless config.dig("feed", "path") == "feed.xml"
    %w[
      _layouts/home.html
      _layouts/archive.html
      _layouts/content_index.html
      _layouts/events.html
      _includes/home_discovery.html
      _includes/related_content.html
      _includes/breadcrumbs.html
    ].each do |required_path|
      errors << "#{required_path}: template de descoberta ausente" unless @root.join(required_path).file?
    end
  rescue Psych::SyntaxError => error
    errors << "_config.yml: YAML invalido (#{error.problem})"
  end

  def validate_level(relative, data, type_config)
    return unless type_config

    level = data["level"]
    policy = type_config["level"]
    errors << "#{relative}: level e obrigatorio para type '#{data["type"]}'" if policy == "required" && !present?(level)
    errors << "#{relative}: level nao se aplica a type '#{data["type"]}'" if policy == "forbidden" && present?(level)
    errors << "#{relative}: level invalido '#{level}'" if present?(level) && !@levels.key?(level)
  end

  def validate_tags(relative, tags)
    unless tags.is_a?(Array) && !tags.empty?
      errors << "#{relative}: tags deve ser uma lista YAML nao vazia"
      return
    end

    tags.each do |tag|
      errors << "#{relative}: tag invalida '#{tag}'" unless tag.is_a?(String) && tag.match?(ID_PATTERN)
    end
    errors << "#{relative}: tags duplicadas" unless tags.uniq.length == tags.length
  end

  def validate_post_identity(relative, path, data)
    match = path.basename.to_s.match(POST_FILENAME)
    return errors << "#{relative}: nome deve seguir YYYY-MM-DD-slug.ext" unless match

    slug = data["slug"] || match[:slug]
    errors << "#{relative}: slug invalido '#{slug}'" unless slug.to_s.match?(ID_PATTERN)
    register_unique(@slugs, slug, relative, "slug")
    validate_unique_url(relative, data["permalink"] || "/#{slug}/")
  end

  def validate_dates(relative, path, data)
    match = path.basename.to_s.match(POST_FILENAME)
    return unless match

    published = Date.new(match[:year].to_i, match[:month].to_i, match[:day].to_i)
    if data.key?("date")
      explicit = parse_date(data["date"])
      errors << "#{relative}: date invalida" unless explicit
      published = explicit if explicit
    end

    return unless data.key?("updated")

    updated = parse_date(data["updated"])
    errors << "#{relative}: updated invalida" unless updated
    errors << "#{relative}: updated nao pode ser anterior a date" if updated && updated < published
  rescue Date::Error
    errors << "#{relative}: data invalida no nome do arquivo"
  end

  def validate_type_fields(relative, data)
    case data["type"]
    when "news"
      %w[source_name source_url source_date].each do |field|
        errors << "#{relative}: campo '#{field}' e obrigatorio para news" unless present?(data[field])
      end
      errors << "#{relative}: source_date invalida" if present?(data["source_date"]) && !parse_date(data["source_date"])
    when "event"
      %w[starts_at timezone mode].each do |field|
        errors << "#{relative}: campo '#{field}' e obrigatorio para event" unless present?(data[field])
      end
      starts_at = parse_event_date(data["starts_at"])
      ends_at = parse_event_date(data["ends_at"])
      errors << "#{relative}: starts_at deve ser data ISO 8601 ou data/hora ISO 8601 com timezone" if present?(data["starts_at"]) && !starts_at
      errors << "#{relative}: ends_at deve ser data ISO 8601 ou data/hora ISO 8601 com timezone" if present?(data["ends_at"]) && !ends_at
      errors << "#{relative}: ends_at nao pode ser anterior a starts_at" if starts_at && ends_at && ends_at < starts_at
      errors << "#{relative}: mode invalido '#{data["mode"]}'" if present?(data["mode"]) && !@event_modes.key?(data["mode"])
      errors << "#{relative}: timezone deve usar um identificador IANA" if present?(data["timezone"]) && !data["timezone"].to_s.match?(%r{\A[A-Za-z_]+/[A-Za-z_]+(?:/[A-Za-z_]+)?\z})
    end
  end

  def validate_urls(relative, data)
    URL_FIELDS.each do |field|
      next unless present?(data[field])
      begin
        uri = URI.parse(data[field].to_s)
        errors << "#{relative}: #{field} deve usar http ou https" unless uri.is_a?(URI::HTTP) && present?(uri.host)
      rescue URI::InvalidURIError
        errors << "#{relative}: #{field} invalida"
      end
    end
  end

  def validate_layout(relative, layout)
    return errors << "#{relative}: layout efetivo ausente" unless present?(layout)
    return if @root.join("_layouts", "#{layout}.html").file?

    errors << "#{relative}: layout '#{layout}' nao existe"
  end

  def validate_front_matter_image(relative, data)
    return unless data.key?("image")
    unless data["image"].is_a?(String)
      errors << "#{relative}: image deve ser um caminho em string"
      return
    end
    errors << "#{relative}: image_alt e obrigatorio quando image e definida" unless present?(data["image_alt"])
    validate_local_asset(relative, data["image"], "imagem editorial")
  end

  def validate_body_images(relative, body)
    body.scan(/!\[(?<alt>[^\]]*)\]\((?<source>[^\s\)]+)[^\)]*\)/).each do |alt, source|
      errors << "#{relative}: imagem sem texto alternativo" if alt.strip.empty?
      validate_local_asset(relative, source, "imagem local")
    end
  end

  def validate_local_asset(relative, source, label)
    return if source.match?(%r{\A(?:https?:)?//}) || source.include?("{{")

    asset = source.start_with?("/") ? @root.join(source.delete_prefix("/")) : @root.join(relative.dirname, source)
    errors << "#{relative}: #{label} nao encontrada: #{source}" unless asset.file?
  end

  def collect_internal_links(relative, body)
    body.scan(/(?<!!)\[[^\]]+\]\((?<target>[^\s\)]+)[^\)]*\)/).flatten.each do |target|
      next if target.match?(%r{\A(?:https?:|mailto:|#|//)}) || target.include?("{{")
      @internal_links << [relative, target]
    end
  end

  def validate_internal_links
    @internal_links.each do |relative, target|
      clean = target.split(/[?#]/, 2).first
      next if clean.nil? || clean.empty?

      if clean.start_with?("/")
        next if @urls.key?(normalize_url(clean)) || @root.join(clean.delete_prefix("/")).exist?
      else
        next if @root.join(relative.dirname, clean).exist?
      end
      errors << "#{relative}: link interno nao encontrado: #{target}"
    end
  end

  def validate_docs_adapter
    adapter = @root.join("docs", "docs-vivas.project.yaml")
    return unless adapter.file?

    data = YAML.safe_load(adapter.read, aliases: false) || {}
    body = data["docs_vivas"] || data
    errors << "docs/docs-vivas.project.yaml: version deve ser 1" unless body["version"] == 1
    errors << "docs/docs-vivas.project.yaml: role invalido" unless %w[system frontend_specific backend_specific single_repo].include?(body["role"])
    errors << "docs/docs-vivas.project.yaml: anti_drift.command ausente" unless present?(body.dig("anti_drift", "command"))
    if present?(body.dig("anti_drift", "cwd")) && !@root.join(body.dig("anti_drift", "cwd")).directory?
      errors << "docs/docs-vivas.project.yaml: anti_drift.cwd inexistente"
    end
    %w[standard operational_state_owner].each { |field| validate_doc_path(adapter, body[field], field) }
    validate_doc_path(adapter, body["definition_of_done"], "definition_of_done")
    validate_doc_path(adapter, body.dig("continuity", "owner"), "continuity.owner")
    (body["canonical"] || {}).each { |name, path| validate_doc_path(adapter, path, "canonical.#{name}") }
  rescue Psych::SyntaxError => error
    errors << "docs/docs-vivas.project.yaml: YAML invalido (#{error.problem})"
  end

  def validate_doc_path(adapter, value, field)
    return errors << "#{adapter.relative_path_from(@root)}: '#{field}' ausente" unless present?(value)
    errors << "#{adapter.relative_path_from(@root)}: '#{field}' aponta para path inexistente: #{value}" unless @root.join(value).exist?
  end

  def validate_unique_url(relative, url)
    register_unique(@urls, normalize_url(url), relative, "URL")
  end

  def normalize_url(url)
    value = url.to_s.split(/[?#]/, 2).first
    return "/" if value == "/"
    value.start_with?("/") ? value : "/#{value}"
  end

  def register_unique(registry, key, relative, label)
    if registry.key?(key) && registry[key].to_s != relative.to_s
      errors << "#{relative}: #{label} duplicado com #{registry[key]} (#{key})"
    else
      registry[key] = relative
    end
  end

  def parse_date(value)
    return value.to_date if value.respond_to?(:to_date)
    Date.iso8601(value.to_s)
  rescue Date::Error
    nil
  end

  def parse_datetime(value)
    return value.to_datetime if value.is_a?(Time) || value.is_a?(DateTime)
    text = value.to_s
    return nil unless text.include?("T") && text.match?(/(?:Z|[+-]\d{2}:\d{2})\z/)
    DateTime.iso8601(text)
  rescue Date::Error
    nil
  end

  def parse_event_date(value)
    return if value.nil?

    text = value.to_s
    return DateTime.iso8601("#{text}T00:00:00Z") if text.match?(/\A\d{4}-\d{2}-\d{2}\z/)

    parse_datetime(value)
  rescue Date::Error, ArgumentError
    nil
  end

  def present?(value)
    !value.nil? && !(value.respond_to?(:empty?) && value.empty?) && !value.to_s.strip.empty?
  end
end

def write_self_test_project(root, valid:)
  root.join("_data").mkpath
  root.join("_includes").mkpath
  root.join("_layouts").mkpath
  root.join("_posts").mkpath
  root.join("pages").mkpath
  root.join("_layouts/post.html").write("<!doctype html>")
  root.join("_layouts/default.html").write("<!doctype html>")
  %w[home archive content_index events tag_index].each do |layout|
    root.join("_layouts", "#{layout}.html").write("---\nlayout: default\n---\n")
  end
  %w[home_discovery related_content breadcrumbs].each do |include_name|
    root.join("_includes", "#{include_name}.html").write("fixture")
  end
  root.join("_data/types.yml").write(<<~YAML)
    article:
      label: Artigo
      description: Artigo
      level: optional
      toc: true
      schema: BlogPosting
    tutorial:
      label: Tutorial
      description: Tutorial
      level: required
      toc: true
      schema: TechArticle
    tip:
      label: InfraTip
      description: Dica
      level: required
      toc: false
      schema: TechArticle
    news:
      label: Noticia
      description: Noticia
      level: forbidden
      toc: false
      schema: NewsArticle
    experience:
      label: Experiencia
      description: Experiencia
      level: optional
      toc: true
      schema: BlogPosting
    event:
      label: Evento
      description: Evento
      level: forbidden
      toc: false
      schema: Event
  YAML
  root.join("_data/categories.yml").write("linux-open-source:\n  label: Linux e Open Source\n  description: Linux\n")
  root.join("_data/levels.yml").write("beginner:\n  label: Iniciante\n")
  root.join("_data/statuses.yml").write("published:\n  label: Publicado\n")
  root.join("_data/event_modes.yml").write("online:\n  label: Online\n  schema: https://schema.org/OnlineEventAttendanceMode\n")
  root.join("_data/event_states.yml").write("upcoming:\n  label: Proximo\ntoday:\n  label: Hoje\npast:\n  label: Encerrado\n")
  root.join("_data/navigation.yml").write("- label: Inicio\n  aria_label: Inicio\n  url: /\n  icon: fa-home\n")
  root.join("_config.yml").write("plugins:\n  - jekyll-feed\nfeed:\n  path: feed.xml\n")
  root.join("pages/index.md").write("---\nlayout: default\npermalink: /\n---\n")
  archive_ids = {
    "type" => %w[article tutorial tip news experience event],
    "category" => %w[linux-open-source]
  }
  archive_ids.each do |kind, ids|
    ids.each do |id|
      directory = kind == "type" ? "tipos" : "categorias"
      root.join("pages", "archive-#{kind}-#{id}.md").write("---\nlayout: archive\ntitle: #{id}\narchive_kind: #{kind}\narchive_id: #{id}\npermalink: /conteudo/#{directory}/#{id}/\n---\n")
    end
  end
  root.join("_posts").glob("*").each(&:delete)

  unless valid
    root.join("_posts/2026-08-11-detector.md").write("---\ntitle: Teste\ntype: invalid\ncategory: missing\ntags: linux\nlevel: unknown\nstatus: draft\nimage: /missing.png\n---\n")
    root.join("_posts/2026-08-11-evento-invalido.md").write("---\ntitle: Evento\nsummary: Evento invalido\ntype: event\ncategory: linux-open-source\ntags:\n  - linux\nlevel: beginner\nstatus: published\ntimezone: UTC\nmode: presencial\n---\n")
    return
  end

  fixtures = {
    "2026-08-11-artigo.md" => "title: Artigo\nsummary: Artigo valido\ntype: article\ncategory: linux-open-source\ntags:\n  - linux\nstatus: published",
    "2026-08-11-tutorial.md" => "title: Tutorial\nsummary: Tutorial valido\ntype: tutorial\ncategory: linux-open-source\ntags:\n  - linux\nlevel: beginner\nstatus: published",
    "2026-08-11-dica.md" => "title: Dica\nsummary: Dica valida\ntype: tip\ncategory: linux-open-source\ntags:\n  - linux\nlevel: beginner\nstatus: published",
    "2026-08-11-noticia.md" => "title: Noticia\nsummary: Noticia valida\ntype: news\ncategory: linux-open-source\ntags:\n  - linux\nstatus: published\nsource_name: Fonte\nsource_url: https://example.com/source\nsource_date: 2026-08-10",
    "2026-08-11-experiencia.md" => "title: Experiencia\nsummary: Experiencia valida\ntype: experience\ncategory: linux-open-source\ntags:\n  - linux\nstatus: published",
    "2026-08-11-evento.md" => "title: Evento\nsummary: Evento valido\ntype: event\ncategory: linux-open-source\ntags:\n  - linux\nstatus: published\nstarts_at: '2026-08-20T19:00:00-03:00'\ntimezone: America/Sao_Paulo\nmode: online"
  }
  fixtures.each do |filename, front_matter|
    root.join("_posts", filename).write("---\n#{front_matter}\n---\n")
  end
end

if ARGV.include?("--self-test")
  Dir.mktmpdir("infratips-validator") do |directory|
    root = Pathname(directory)
    write_self_test_project(root, valid: false)
    invalid_errors = ContentValidator.new(root).run
    abort "Self-test falhou: detector aceitou conteudo invalido" if invalid_errors.empty?
    puts "FAIL confirmado: detector rejeitou fixture invalida (#{invalid_errors.length} erros)."

    write_self_test_project(root, valid: true)
    restored_errors = ContentValidator.new(root).run
    abort "Self-test falhou apos restore:\n#{restored_errors.join("\n")}" unless restored_errors.empty?
    puts "PASS confirmado: fixture restaurada e aceita sem erros."
  end
  exit 0
end

errors = ContentValidator.new(File.expand_path("..", __dir__)).run
if errors.empty?
  puts "Conteudo e documentacao anti-drift validos."
else
  warn errors.join("\n")
  exit 1
end
