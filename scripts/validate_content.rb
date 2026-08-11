#!/usr/bin/env ruby

require "date"
require "pathname"
require "tmpdir"
require "yaml"

class ContentValidator
  FRONT_MATTER = /\A---\s*\n(?<yaml>.*?)\n---\s*\n/m

  def initialize(root)
    @root = Pathname(root)
    @errors = []
    @permalinks = {}
  end

  def run
    files.each { |path| validate(path) }
    @errors
  end

  private

  def files
    [@root.join("_posts"), @root.join("pages")]
      .flat_map { |directory| directory.glob("**/*.{md,markdown,html}") }
      .sort
  end

  def validate(path)
    relative = path.relative_path_from(@root)
    match = path.read.match(FRONT_MATTER)
    return @errors << "#{relative}: front matter ausente ou invalido" unless match

    data = YAML.safe_load(match[:yaml], permitted_classes: [Date, Time], aliases: false) || {}
    validate_required(relative, data)
    validate_layout(relative, data["layout"])
    validate_permalink(relative, data["permalink"])
    validate_images(relative, path.read)
  rescue Psych::SyntaxError => error
    @errors << "#{relative}: YAML invalido (#{error.problem})"
  end

  def validate_required(relative, data)
    required = relative.to_s.start_with?("_posts/") ? %w[layout title date category] : %w[layout]
    required.each do |field|
      @errors << "#{relative}: campo obrigatorio '#{field}' ausente" if data[field].to_s.strip.empty?
    end
  end

  def validate_layout(relative, layout)
    return if layout.to_s.empty?
    return if @root.join("_layouts", "#{layout}.html").file?

    @errors << "#{relative}: layout '#{layout}' nao existe"
  end

  def validate_permalink(relative, permalink)
    return if permalink.to_s.empty?
    if @permalinks.key?(permalink)
      @errors << "#{relative}: permalink duplicado com #{@permalinks[permalink]}"
    else
      @permalinks[permalink] = relative
    end
  end

  def validate_images(relative, body)
    body.scan(/!\[(?<alt>[^\]]*)\]\((?<source>[^\s\)]+)[^\)]*\)/).each do |alt, source|
      @errors << "#{relative}: imagem sem texto alternativo" if alt.strip.empty?
      next if source.match?(%r{\A(?:https?:)?//}) || source.include?("{{")

      asset = source.start_with?("/") ? @root.join(source.delete_prefix("/")) : @root.join(relative.dirname, source)
      @errors << "#{relative}: imagem local nao encontrada: #{source}" unless asset.file?
    end
  end
end

if ARGV.include?("--self-test")
  Dir.mktmpdir("infratips-validator") do |directory|
    root = Pathname(directory)
    root.join("_posts").mkpath
    root.join("pages").mkpath
    root.join("_layouts").mkpath
    root.join("_layouts/default.html").write("<!doctype html>")
    root.join("_posts/2026-01-01-invalid.md").write("---\nlayout: missing\n---\n![](/missing.png)\n")
    errors = ContentValidator.new(root).run
    abort "Self-test falhou: detector aceitou conteudo invalido" if errors.empty?
    puts "Self-test OK: detector rejeitou conteudo invalido (#{errors.length} erros)."
  end
  exit 0
end

errors = ContentValidator.new(File.expand_path("..", __dir__)).run
if errors.empty?
  puts "Conteudo valido."
else
  warn errors.join("\n")
  exit 1
end
