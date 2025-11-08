# Casos de Uso - RptCatalogoMerc

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Mercado Municipal

**Descripción:** Un usuario autorizado desea registrar un nuevo mercado municipal en el sistema.

**Precondiciones:**
El usuario está autenticado y tiene permisos de alta.

**Pasos a seguir:**
1. El usuario ingresa a la página de Catálogo de Mercados.
2. Hace clic en 'Agregar Mercado'.
3. Llena el formulario con los datos requeridos.
4. Hace clic en 'Guardar'.
5. El sistema envía la petición a /api/execute con action 'createCatalogoMercado'.
6. El backend ejecuta el SP y retorna éxito.

**Resultado esperado:**
El nuevo mercado aparece en el listado y está disponible para futuras operaciones.

**Datos de prueba:**
{ "oficina": 2, "num_mercado_nvo": 20, "categoria": 1, "descripcion": "Mercado San Juan", "cuenta_ingreso": 44502, "cuenta_energia": 0, "id_zona": 2, "tipo_emision": "M", "usuario_id": 1 }

---

## Caso de Uso 2: Edición de un Mercado Existente

**Descripción:** Un usuario necesita actualizar la descripción y cuenta de ingreso de un mercado existente.

**Precondiciones:**
El mercado existe y el usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario localiza el mercado en el listado.
2. Hace clic en 'Editar'.
3. Modifica la descripción y cuenta de ingreso.
4. Hace clic en 'Guardar'.
5. El sistema envía la petición a /api/execute con action 'updateCatalogoMercado'.
6. El backend ejecuta el SP y retorna éxito.

**Resultado esperado:**
Los cambios se reflejan en el listado.

**Datos de prueba:**
{ "oficina": 2, "num_mercado_nvo": 20, "categoria": 1, "descripcion": "Mercado San Juan Actualizado", "cuenta_ingreso": 44503, "cuenta_energia": 0, "id_zona": 2, "tipo_emision": "M", "usuario_id": 1 }

---

## Caso de Uso 3: Generación de Reporte PDF del Catálogo

**Descripción:** El usuario desea obtener un reporte PDF actualizado del catálogo de mercados.

**Precondiciones:**
Existen mercados registrados.

**Pasos a seguir:**
1. El usuario hace clic en 'Generar Reporte PDF'.
2. El sistema envía la petición a /api/execute con action 'getCatalogoMercadosReporte'.
3. El backend ejecuta el SP y retorna la URL del PDF.

**Resultado esperado:**
El usuario puede descargar el PDF generado.

**Datos de prueba:**
{}

---

