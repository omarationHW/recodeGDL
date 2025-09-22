# Documentación Técnica: Migración Formulario AuxRep (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario "AuxRep" del sistema original en Delphi, migrado a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es listar el padrón de concesionarios filtrado por tabla y vigencia, con posibilidad de exportar/imprimir el resultado.

## 2. Arquitectura
- **Backend**: Laravel Controller con endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js independiente, página completa, sin tabs.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ "eRequest": { "action": "...", "params": { ... } } }`
- **Salida**: `{ "eResponse": { ... } }`
- **Acciones soportadas**:
  - `getPadron`: Listar padrón filtrado
  - `getTablas`: Obtener info de la tabla
  - `getEtiquetas`: Obtener etiquetas de la tabla
  - `getVigencias`: Listar vigencias disponibles
  - `printPadron`: Exportar padrón (simulado como CSV)

## 4. Stored Procedures
- **sp34_padron**: Devuelve el padrón de concesionarios según tabla y vigencia.
- **sp34_tablas**: Devuelve info de la tabla y sus unidades.
- **sp34_etiq**: Devuelve las etiquetas asociadas a la tabla.
- **sp34_vigencias**: Devuelve las vigencias disponibles para la tabla.

## 5. Frontend (Vue.js)
- Página independiente `/aux-rep`.
- Selector de vigencia, botón Buscar, botón Imprimir.
- Tabla con columnas: Control, Concesionario, Ubicación.
- Exportación a CSV (simulación de impresión).
- Breadcrumb de navegación.
- Manejo de errores y estados de carga.

## 6. Seguridad
- Todas las acciones validadas en el backend.
- Parámetros validados y tipados.
- Errores controlados y logueados.

## 7. Consideraciones
- El endpoint es único y flexible para futuras extensiones.
- El frontend es desacoplado y puede ser integrado en cualquier SPA.
- La lógica de negocio reside en los stored procedures para facilitar mantenimiento y portabilidad.

## 8. Ejemplo de Llamada API
```json
{
  "eRequest": {
    "action": "getPadron",
    "params": { "par_tabla": 3, "par_vigencia": "TODOS" }
  }
}
```

## 9. Ejemplo de Respuesta API
```json
{
  "eResponse": {
    "padron": [
      { "control": "001-A", "concesionario": "Juan Pérez", "ubicacion": "Mercado 1" },
      ...
    ]
  }
}
```

## 10. Flujo de la Página
1. Al cargar, obtiene info de tabla, etiquetas y vigencias.
2. Por defecto, muestra el padrón con vigencia "TODOS".
3. El usuario puede filtrar por vigencia y buscar.
4. El usuario puede exportar el resultado a CSV.

## 11. Extensibilidad
- El endpoint y los SP permiten agregar más filtros o columnas fácilmente.
- El frontend puede ser adaptado a otros formularios similares.
