# Documentación Técnica: repdoc

## Análisis Técnico

# Documentación Técnica: Migración Formulario repdoc (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario `repdoc` permite consultar e imprimir los requisitos documentales para el trámite de licencias municipales, según el giro seleccionado. La migración implica separar la lógica en backend (Laravel + PostgreSQL) y frontend (Vue.js), usando un API RESTful unificado y procedimientos almacenados para la lógica SQL.

## 2. Arquitectura
- **Backend:** Laravel Controller único (`RepdocController`) con endpoint `/api/execute` que recibe un objeto `eRequest` con la acción y parámetros.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación y búsqueda de giros y requisitos.
- **Base de Datos:** PostgreSQL, lógica SQL encapsulada en stored procedures (`sp_repdoc_*`).

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getGiros|getGiroById|getRequisitosByGiro|printRequisitos",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

## 4. Stored Procedures
- Toda la lógica de consulta de giros y requisitos se realiza vía SPs:
  - `sp_repdoc_get_giros(tipo)`
  - `sp_repdoc_get_giro_by_id(id_giro)`
  - `sp_repdoc_get_requisitos_by_giro(id_giro)`

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite buscar por actividad, seleccionar giro, ver tipo y descripción, y listar requisitos.
- Botón de impresión usa `window.print()` o puede integrarse con generación de PDF desde backend.
- Navegación breadcrumb incluida.

## 6. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej. JWT o sesión Laravel).
- Validar permisos de usuario para impresión si aplica.

## 7. Consideraciones de Migración
- Los queries SQL Delphi se migran a SPs PostgreSQL.
- El flujo de selección de giro y obtención de requisitos es idéntico al original.
- El reporte impreso puede ser generado en frontend (HTML/CSS) o backend (PDF).

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar la estructura del endpoint.
- Los SPs pueden ser reutilizados por otros módulos.

## 9. Pruebas
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad.

---

## Casos de Prueba

# Casos de Prueba para Formulario repdoc

## Caso 1: Consulta de requisitos para giro existente
- **Entrada:** id_giro=1201
- **Acción:** getRequisitosByGiro
- **Esperado:** Lista de requisitos no vacía, cada requisito tiene descripción.

## Caso 2: Consulta de requisitos para giro inexistente
- **Entrada:** id_giro=999999
- **Acción:** getRequisitosByGiro
- **Esperado:** Lista vacía.

## Caso 3: Búsqueda de giros por texto
- **Entrada:** actividad='farmacia'
- **Acción:** getGiros + filtro frontend
- **Esperado:** Solo giros con 'farmacia' en descripción.

## Caso 4: Impresión de requisitos
- **Acción:** printRequisitos con id_giro válido
- **Esperado:** Se genera reporte con encabezado, giro, tipo, actividad y requisitos.

## Caso 5: Selección de giro y actualización de requisitos
- **Acción:** Seleccionar un giro diferente
- **Esperado:** Se actualiza la información de giro y la lista de requisitos.

## Casos de Uso

# Casos de Uso - repdoc

**Categoría:** Form

## Caso de Uso 1: Consulta de requisitos para un giro específico

**Descripción:** El usuario desea conocer los requisitos documentales para tramitar una licencia municipal para un giro determinado.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo de requisitos documentales.

**Pasos a seguir:**
1. El usuario accede a la página de requisitos documentales.
2. Teclea parte de la actividad o selecciona el giro en el combo.
3. El sistema muestra el tipo y descripción del giro.
4. El sistema lista los requisitos asociados al giro.

**Resultado esperado:**
Se muestran correctamente los requisitos documentales para el giro seleccionado.

**Datos de prueba:**
Actividad: 'RESTAURANTE'; Giro: id_giro=1201

---

## Caso de Uso 2: Impresión de requisitos documentales

**Descripción:** El usuario necesita imprimir el listado de requisitos para un giro seleccionado.

**Precondiciones:**
El usuario ya seleccionó un giro y visualiza los requisitos.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Imprimir'.
2. El sistema genera una vista imprimible del reporte.
3. El usuario imprime o guarda como PDF.

**Resultado esperado:**
El reporte impreso contiene el encabezado, giro, tipo, actividad y todos los requisitos.

**Datos de prueba:**
Giro: id_giro=1302 (Ejemplo: 'BAR')

---

## Caso de Uso 3: Búsqueda de giros por actividad

**Descripción:** El usuario busca giros filtrando por texto de actividad.

**Precondiciones:**
El usuario está en la página de requisitos documentales.

**Pasos a seguir:**
1. El usuario escribe 'farmacia' en el campo de actividad.
2. El sistema filtra y muestra solo los giros que contienen 'farmacia' en la descripción.

**Resultado esperado:**
Solo se muestran giros relacionados con farmacias.

**Datos de prueba:**
Actividad: 'farmacia'

---


