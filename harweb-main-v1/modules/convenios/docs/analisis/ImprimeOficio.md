# Documentación Técnica: Migración Formulario ImprimeOficio (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos**: PostgreSQL 13+ (todas las operaciones encapsuladas en stored procedures)
- **Patrón de integración**: eRequest/eResponse (API unificada)

## Flujo General
1. El usuario accede a la página de impresión de oficio/pagaré.
2. Ingresa los datos del convenio (letras, número, año, tipo) y presiona "Buscar".
3. El frontend llama a `/api/execute` con `operation: 'buscar'` y los parámetros.
4. El backend llama al SP `sp_imprime_oficio_buscar_convenio` y retorna los datos del convenio y firmas.
5. Si el convenio es válido y no tiene errores, se habilitan los botones para imprimir oficio/pagaré.
6. Al presionar "Imprimir Oficio" o "Imprimir Pagaré", se llama a `/api/execute` con la operación correspondiente, que retorna la URL del PDF generado.

## API Backend
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ eRequest: { operation: string, params: object } }`
- **Salida**: `{ eResponse: { ... } }`
- **Operaciones soportadas**:
  - `buscar`: Busca convenio y retorna datos completos.
  - `imprimir_oficio`: Genera PDF del oficio y retorna URL/base64.
  - `imprimir_pagare`: Genera PDF del pagaré y retorna URL/base64.
  - `salir`, `otro`, `testigo1`, `testigo2`, `firma_titular`, `cargo_titular`: Acciones de UI.

## Stored Procedures
- Toda la lógica de negocio y validación reside en SPs de PostgreSQL.
- Los SPs devuelven datos en formato tabla o JSON según el caso.
- Ejemplo de SPs:
  - `sp_imprime_oficio_buscar_convenio`: Devuelve todos los datos del convenio.
  - `sp_imprime_oficio_adeudos_sin_desglose`: Devuelve parcialidades sin desglose.
  - `sp_imprime_oficio_firma`: Devuelve datos de firmas.
  - `sp_imprime_oficio_datos_oficio`: Devuelve todos los textos y datos para el oficio.
  - `sp_imprime_oficio_datos_pagare`: Devuelve todos los textos y datos para el pagaré.

## Frontend (Vue.js)
- Página independiente `/imprime-oficio`.
- Formulario para búsqueda de convenio.
- Visualización de datos del convenio y firmas.
- Botones para imprimir oficio/pagaré, reiniciar y salir.
- Visualización del PDF generado en un iframe.
- Manejo de errores y validaciones.

## Seguridad
- Todas las operaciones requieren autenticación JWT (middleware Laravel).
- Validación de parámetros en backend y frontend.
- Los SPs validan la vigencia y consistencia de los datos.

## Consideraciones de Migración
- Los reportes (oficio/pagaré) se generan en backend y se exponen como PDFs.
- Las cantidades en letras se generan en el SP usando una función auxiliar (`num2letras`).
- El frontend nunca accede directamente a la base de datos.
- El endpoint es unificado para facilitar integración y pruebas.

# Esquema de Base de Datos
- `ta_17_conv_diverso`, `ta_17_conv_d_resto`, `ta_17_referencia`, `ta_17_adeudos_div`, `ta_17_desg_parcial`, `ta_17_firmaconv`, `ta_17_elaboroficio`, etc.

# Ejemplo de Llamada API
```json
POST /api/execute
{
  "eRequest": {
    "operation": "buscar",
    "params": {
      "letras": "ZC1",
      "numero": 123,
      "axo": 2024,
      "tipo": 1
    }
  }
}
```

# Ejemplo de Respuesta
```json
{
  "eResponse": {
    "status": "ok",
    "convenio": { ... },
    "firma": { ... }
  }
}
```

# Notas
- Para la generación de PDFs, se recomienda usar un microservicio o paquete Laravel (ej: barryvdh/laravel-dompdf) que consuma los datos del SP y genere el reporte.
- Los textos legales y plantillas deben mantenerse en la base de datos o en archivos de configuración para facilitar cambios futuros.
