# Documentación Técnica: Migración Formulario Adeudos_Ins (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API, endpoint único `/api/execute` (POST), patrón eRequest/eResponse.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (NO tabs).
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.
- **Catálogos**: Tablas `cat_tipo_aseo`, `cat_operacion`.
- **Transacciones**: Todas las operaciones de inserción usan transacciones.

## 2. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Request**:
  ```json
  {
    "action": "adeudos_ins_insert",
    "params": {
      "contrato": 1234,
      "ctrol_aseo": 9,
      "ejercicio": 2024,
      "aso": 2024,
      "mes": "06",
      "ctrol_operacion": 7,
      "exedencias": 2,
      "oficio": "OF-1234"
    }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "Exedencia registrada correctamente",
    "data": null
  }
  ```

## 3. Lógica de Negocio
- **Validaciones**:
  - El contrato debe existir, estar vigente y el año debe ser válido.
  - La fecha de exedencia no puede ser menor al inicio de obligación.
  - Debe existir cuota normal para el periodo.
  - No debe existir exedencia/contenedor para el mismo periodo y operación.
  - El año debe estar entre 1989 y el año actual.
- **Inserción**:
  - Se calcula el importe: `exedencias * costo_exed`.
  - Se inserta en `ta_16_pagos` con status 'V'.

## 4. Stored Procedures
- Toda la lógica de validación e inserción está en `sp_adeudos_ins_insert`.
- Catálogos y validación de contrato en SPs separados.

## 5. Vue.js Frontend
- Página independiente, sin tabs.
- Formulario reactivo, validación básica en frontend.
- Llama a `/api/execute` para catálogos, validación y registro.
- Mensajes de éxito/error claros.

## 6. Seguridad
- El endpoint requiere autenticación (Laravel Sanctum/JWT recomendado).
- El usuario autenticado se usa como `usuario` en la inserción.

## 7. Extensibilidad
- El endpoint y SPs permiten agregar más acciones y lógica sin modificar el frontend.

## 8. Pruebas
- Casos de uso y pruebas cubren validaciones, inserción correcta y errores de negocio.

---

# Esquema de Tablas Relevantes

- **ta_16_contratos**: Contratos principales.
- **ta_16_pagos**: Pagos, exedencias, contenedores.
- **cat_tipo_aseo**: Catálogo de tipo de aseo.
- **cat_operacion**: Catálogo de operaciones.

---

# Flujo de la Página Adeudos_Ins

1. Al cargar, obtiene catálogos (`adeudos_ins_get_catalogs`).
2. El usuario llena el formulario y envía.
3. Se valida el contrato (`adeudos_ins_validate_contrato`).
4. Si es válido, se ejecuta la inserción (`adeudos_ins_insert`).
5. Se muestra mensaje de éxito o error.

---

# Notas de Migración
- El formulario Delphi usaba queries directas y lógica en el frontend. Ahora toda la lógica crítica está en el backend y SPs.
- El frontend es desacoplado y sólo consume el API.
- El endpoint es extensible para otros formularios/procesos.
