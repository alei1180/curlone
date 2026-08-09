window.addEventListener("load", () => {
    window.ui = SwaggerUIBundle({
        url: "/static/openapi.json",
        dom_id: "#swagger-ui",
        deepLinking: true,
        docExpansion: "full",
        presets: [
            SwaggerUIBundle.presets.apis,
            SwaggerUIStandalonePreset,
        ],
        presets_config: {
            SwaggerUIStandalonePreset: {
                TopbarPlugin: false,
            },
        },
        plugins: [
            SwaggerUIBundle.plugins.DownloadUrl,
        ],
        layout: "StandaloneLayout",
    });
});
