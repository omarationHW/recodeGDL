# Documentación Técnica: Migración de Formulario Gen_ArcDiario (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la generación de archivos diarios de "remesa" a partir de información almacenada en la base de datos. El proceso incluye la consulta de periodos, ejecución de un proceso de generación de remesa (SP), conteo de folios por tipo, y la generación/descarga de un archivo de texto plano con los datos de la remesa.

## 2. Arquitectura
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente)
- **Base de Datos:** PostgreSQL (con stored procedures)
- **Almacenamiento de archivos:** Laravel Storage (local)

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute` (POST)
- **Request:**
  - `eRequest`: nombre de la operación
  - `params`: parámetros específicos de la operación
- **Response:**
  - `eResponse`: objeto con `status`, `message`, y `data`

### Operaciones soportadas
- `get_periodo_diario`: Obtiene el periodo de la última generación diaria
- `get_periodo_altas`: Obtiene el periodo de la última generación de altas
- `ejecutar_remesa`: Ejecuta el proceso de generación de remesa (SP)
- `buscar_folios_remesa`: Cuenta los folios de una remesa por tipoact
- `generar_archivo_remesa`: Genera y almacena el archivo de texto de la remesa, retorna URL de descarga

## 4. Stored Procedures (PostgreSQL)
- **sp14_remesa:** Proceso principal de generación de remesa
- **get_periodo_diario:** Consulta de periodo diario
- **get_periodo_altas:** Consulta de periodo de altas
- **buscar_folios_remesa:** Conteo de folios por tipoact
- **generar_archivo_remesa:** Devuelve los registros para el archivo de texto

## 5. Frontend (Vue.js)
- Página independiente `/gen-arc-diario`
- Permite:
  - Visualizar periodos
  - Seleccionar fechas de generación
  - Ejecutar proceso de remesa
  - Ver resumen de folios
  - Generar y descargar archivo de texto
- Navegación breadcrumb incluida

## 6. Flujo de Usuario
1. El usuario accede a la página y visualiza los periodos actuales.
2. Selecciona las fechas de generación y ejecuta la remesa.
3. El sistema muestra el resumen y conteo de folios.
4. Si hay folios, permite generar el archivo de texto y descargarlo.

## 7. Seguridad
- Solo usuarios autenticados pueden acceder a la API y la página.
- Los archivos generados se almacenan temporalmente y solo son accesibles mediante URL segura.

## 8. Consideraciones
- El proceso de generación de remesa debe ser atómico (transaccional).
- El archivo de texto se genera solo si existen registros.
- El endpoint `/api/remesa/download/{filename}` permite la descarga segura del archivo generado.

## 9. Errores y Mensajes
- Todos los errores se retornan en el campo `message` de `eResponse`.
- Mensajes de éxito y advertencia se muestran en la interfaz.

## 10. Pruebas
- Casos de uso y pruebas detallados en las siguientes secciones.
