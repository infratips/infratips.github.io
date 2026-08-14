const { test, expect } = require("@playwright/test");
const AxeBuilder = require("@axe-core/playwright").default;

test("home renderiza com estrutura, SEO e sem overflow", async ({ page }, testInfo) => {
  await page.goto("/");

  await expect(page.locator("html")).toHaveAttribute("lang", "pt-BR");
  await expect(page.locator("h1")).toHaveCount(1);
  await expect(page.locator("main")).toBeVisible();
  await expect(page.locator('link[rel="canonical"]')).toHaveAttribute(
    "href",
    "https://www.infratips.com.br/"
  );
  await expect(page.locator('meta[property="og:title"]')).toHaveCount(1);
  await expect(page.locator("article[itemtype='https://schema.org/WebSite']")).toBeVisible();
  await expect(page.locator("#comece-aqui")).toBeVisible();
  await expect(page.getByRole("heading", { name: "> recentes" })).toBeVisible();
  await expect(page.getByRole("heading", { name: "> infratips" })).toBeVisible();
  await expect(page.getByRole("heading", { name: "> eventos" })).toBeVisible();

  const hasOverflow = await page.evaluate(
    () => document.documentElement.scrollWidth > document.documentElement.clientWidth
  );
  expect(hasOverflow).toBe(false);

  await page.screenshot({
    path: testInfo.outputPath(`home-${testInfo.project.name}.png`),
    fullPage: true
  });
});

test("header oferece controles e links sociais acessiveis", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByRole("link", { name: "Eleu Carlos no LinkedIn" })).toHaveAttribute(
    "href",
    "https://www.linkedin.com/in/eleucarlos/"
  );
  for (const name of ["Explorar conteúdo", "Comece aqui", "Eventos", "Sobre o InfraTips", "Carreira, certificacoes e labs"]) {
    await expect(page.getByRole("link", { name })).toBeVisible();
  }

  const undersized = await page.locator(".site_header a:visible, .site_header button:visible").evaluateAll(
    (elements) => elements
      .map((element) => {
        const rect = element.getBoundingClientRect();
        return { label: element.getAttribute("aria-label") || element.textContent, width: rect.width, height: rect.height };
      })
      .filter(({ width, height }) => width < 43 || height < 43)
  );
  expect(undersized).toEqual([]);

  const overlappingControls = await page.locator(".header_nav a:visible, .header_nav button:visible").evaluateAll(
    (elements) => elements.flatMap((element, index) => {
      const current = element.getBoundingClientRect();
      return elements.slice(index + 1).flatMap((otherElement) => {
        const other = otherElement.getBoundingClientRect();
        const overlaps =
          current.left < other.right &&
          current.right > other.left &&
          current.top < other.bottom &&
          current.bottom > other.top;

        return overlaps
          ? [{
              first: element.getAttribute("aria-label") || element.textContent.trim(),
              second: otherElement.getAttribute("aria-label") || otherElement.textContent.trim()
            }]
          : [];
      });
    })
  );
  expect(overlappingControls).toEqual([]);

  await page.keyboard.press("Tab");
  await expect(page.getByRole("link", { name: "Pular para o conteudo" })).toBeFocused();
  await page.getByRole("button", { name: /Matrix/ }).focus();
  await page.keyboard.press("Enter");
  await expect(page.locator("html")).toHaveAttribute("data-matrix-state", /paused|running/);
});

test("artigo possui semantica e imagem descritiva", async ({ page }) => {
  await page.goto("/beginproject/");

  await expect(page.locator("article[itemtype='https://schema.org/BlogPosting']")).toBeVisible();
  await expect(page.locator("h1")).toHaveCount(1);
  await expect(page.locator("article img")).toHaveAttribute("alt", /InfraTips/);
  await expect(page.locator("time.dt-published")).toContainText("02/05/2020");
});

test("InfraTip deriva template, taxonomia e controles do tipo", async ({ page }, testInfo) => {
  await page.goto("/verificar-portas-em-escuta-no-linux/");

  await expect(page.locator("article[itemtype='https://schema.org/TechArticle']")).toBeVisible();
  await expect(page.getByRole("heading", { level: 1 })).toContainText(
    "Como verificar portas em escuta no Linux"
  );
  await expect(page.locator(".post_info")).toContainText("InfraTip");
  await expect(page.locator(".post_info")).toContainText("Linux e Open Source");
  await expect(page.locator(".post_info")).toContainText("Iniciante");
  await expect(page.locator("#toc_toggle")).toHaveCount(0);
  await expect(page.locator("pre code").first()).toContainText("ss -lntup");
  await expect(page.locator(".breadcrumbs[itemtype='https://schema.org/BreadcrumbList']")).toBeVisible();

  await page.screenshot({
    path: testInfo.outputPath(`infratip-${testInfo.project.name}.png`),
    fullPage: true
  });
});

test("diretorios permitem navegar por tipo, categoria, tags e eventos", async ({ page }, testInfo) => {
  await page.goto("/conteudo/");
  await expect(page.getByRole("heading", { level: 1, name: "Conteúdo" })).toBeVisible();
  await expect(page.getByRole("link", { name: "InfraTip", exact: true })).toHaveAttribute(
    "href",
    "/conteudo/tipos/tip/"
  );
  await expect(page.getByRole("link", { name: "Linux e Open Source" })).toHaveAttribute(
    "href",
    "/conteudo/categorias/linux-open-source/"
  );
  await page.screenshot({
    path: testInfo.outputPath(`conteudo-${testInfo.project.name}.png`),
    fullPage: true
  });

  await page.goto("/conteudo/tipos/tip/");
  await expect(page.getByRole("link", { name: "Como verificar portas em escuta no Linux" })).toBeVisible();
  await expect(page.locator(".breadcrumbs")).toContainText("Conteúdo");

  await page.goto("/conteudo/tags/");
  await expect(page.getByRole("heading", { name: "#linux" })).toBeVisible();

  await page.goto("/eventos/");
  await expect(page.getByRole("link", { name: "KubeCon + CloudNativeCon North America 2026" })).toBeVisible();
  await page.screenshot({
    path: testInfo.outputPath(`eventos-${testInfo.project.name}.png`),
    fullPage: true
  });
});

test("trilhas e carreira oferecem proximos passos sem overflow", async ({ page }, testInfo) => {
  await page.goto("/comece-aqui/");
  await expect(page.getByRole("heading", { level: 1, name: "Comece aqui" })).toBeVisible();
  await expect(page.getByRole("heading", { level: 2, name: "> Quero comecar em Seguranca" })).toBeVisible();
  await expect(page.getByRole("heading", { level: 2, name: "> Quero explorar Programacao e IA" })).toBeVisible();
  await expect(
    page
      .getByRole("region", { name: "> Quero explorar Programacao e IA" })
      .getByRole("link", { name: "Automatizando uma checagem HTTP com Python" })
  ).toBeVisible();

  await page.goto("/carreira/");
  await expect(page.getByRole("heading", { level: 1, name: "Carreira, certificacoes e labs" })).toBeVisible();
  await expect(page.getByRole("heading", { level: 2, name: "> proximos_passos" })).toBeVisible();
  await expect(page.getByRole("link", { name: "Escolha uma trilha de entrada" })).toHaveAttribute(
    "href",
    "/comece-aqui/#track_start-in-it"
  );

  const hasOverflow = await page.evaluate(
    () => document.documentElement.scrollWidth > document.documentElement.clientWidth
  );
  expect(hasOverflow).toBe(false);
  await page.screenshot({ path: testInfo.outputPath(`carreira-${testInfo.project.name}.png`), fullPage: true });
});

test("tutorial e experiencia recebem guias de leitura por tipo", async ({ page }) => {
  await page.goto("/verificar-endpoint-http-com-python/");
  await expect(page.locator(".content_type_guide_tutorial")).toContainText("procedimento");

  await page.goto("/aplicacao-funciona-localmente-mas-nao-externamente/");
  await expect(page.locator(".content_type_guide_experience")).toContainText("Diagnostico");
  await expect(page.locator(".content_type_guide_experience")).toContainText("Resultado");
});

test("evento curado aceita datas sem horario inventado", async ({ page }) => {
  await page.goto("/kubecon-cloudnativecon-north-america-2026/");

  await expect(page.locator("article[itemtype='https://schema.org/Event']")).toBeVisible();
  await expect(page.locator(".content_details")).toContainText("09/11/2026");
  await expect(page.locator(".content_details")).not.toContainText("00:00");
  await expect(page.getByRole("link", { name: "Acessar inscrição" })).toHaveAttribute(
    "href",
    "https://events.linuxfoundation.org/kubecon-cloudnativecon-north-america/"
  );
});

test("RSS geral e sitemap sao publicados", async ({ request }) => {
  const feed = await request.get("/feed.xml");
  expect(feed.ok()).toBe(true);
  expect(feed.headers()["content-type"]).toContain("xml");
  const feedBody = await feed.text();
  expect(feedBody).toContain("Como verificar portas em escuta no Linux");

  const sitemap = await request.get("/sitemap.xml");
  expect(sitemap.ok()).toBe(true);
  expect(await sitemap.text()).toContain("/conteudo/tipos/tip/");
});

test("controles de leitura funcionam por teclado", async ({ page }) => {
  await page.goto("/beginproject/");

  const maximize = page.locator("#maximize_btn");
  if (await maximize.isVisible()) {
    await maximize.focus();
    await page.keyboard.press("Enter");
    await expect(maximize).toHaveAttribute("aria-pressed", "true");
    await expect(page.locator(".terminal_shell")).toHaveClass(/is_maximized/);
  }

  const toc = page.locator("#toc_toggle");
  await toc.focus();
  await page.keyboard.press("Enter");
  await expect(page.locator("#popup_toc")).toBeVisible();
  await page.keyboard.press("Escape");
  await expect(page.locator("#popup_toc")).toBeHidden();

  const next = page.locator("#next_btn");
  await next.focus();
  await page.keyboard.press("Enter");
  await expect.poll(() => page.evaluate(() => window.scrollY)).toBeGreaterThan(0);
});

test("paginas principais nao possuem violacoes criticas de acessibilidade", async ({ page }) => {
  for (const path of [
    "/",
    "/conteudo/",
    "/conteudo/tipos/tip/",
    "/eventos/",
    "/comece-aqui/",
    "/carreira/",
    "/sobre/",
    "/beginproject/",
    "/verificar-portas-em-escuta-no-linux/"
  ]) {
    await page.goto(path);
    const results = await new AxeBuilder({ page }).analyze();
    expect(results.violations.filter(({ impact }) => impact === "critical"), path).toEqual([]);
  }
});

test.describe("movimento reduzido", () => {
  test("Matrix inicia pausada e pode ser reativada", async ({ page }) => {
    await page.emulateMedia({ reducedMotion: "reduce" });
    await page.goto("/");
    await expect(page.locator("html")).toHaveAttribute("data-matrix-state", "paused");

    const canvas = page.locator("#matrix_canvas");
    const before = await canvas.screenshot();
    await page.waitForTimeout(200);
    expect(await canvas.screenshot()).toEqual(before);

    await page.getByRole("button", { name: /Matrix/ }).click();
    await expect(page.locator("html")).toHaveAttribute("data-matrix-state", "running");
  });
});
