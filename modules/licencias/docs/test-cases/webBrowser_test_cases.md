# Casos de Prueba: WebBrowserPage

| Caso | Descripción | Entrada | Acción | Resultado Esperado |
|------|-------------|---------|--------|-------------------|
| TC01 | Navegación exitosa a URL válida | https://www.wikipedia.org | Blur en campo URL | Iframe muestra Wikipedia |
| TC02 | URL inválida | abc123 | Blur en campo URL | Mensaje de error: 'Invalid URL format' |
| TC03 | Campo vacío | (vacío) | Blur en campo URL | Mensaje de error: 'La URL es obligatoria.' |
| TC04 | URL con protocolo no permitido | ftp://example.com | Blur en campo URL | Mensaje de error: 'Invalid URL format' |
| TC05 | URL con espacios | https://www. google.com | Blur en campo URL | Mensaje de error: 'Invalid URL format' |
| TC06 | Navegación a URL por defecto | (no acción) | Al cargar la página | Iframe muestra https://modulos.guadalajara.gob.mx/ubicacion/posxybus.php |
