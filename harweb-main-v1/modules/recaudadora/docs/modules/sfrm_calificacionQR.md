# Documentación Técnica: Migración Formulario sfrm_calificacionQR

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `sfrm_calificacionQR` a una arquitectura moderna basada en Laravel (API RESTful), Vue.js (SPA) y PostgreSQL (procedimientos almacenados). Permite consultar e imprimir la calificación de una multa, mostrando datos principales, artículos relacionados y un código QR generado dinámicamente.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 2/3 SPA, componente de página independiente.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": "get_calificacion_qr_full",
    "params": { "id_multa": 123 }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": {
        "calificacion": { ... },
        "articulos": [ ... ]
      },
      "error": null
    }
  }
  ```

## 4. Stored Procedures
- **sp_get_calificacion_qr:** Devuelve los datos principales de la multa.
- **sp_get_multas_articulos:** Devuelve los artículos asociados a la multa.

## 5. Lógica de Negocio
- El usuario ingresa un ID de multa.
- Se consulta la información principal y los artículos asociados vía stored procedures.
- Se genera un string QR con los campos clave y se muestra visualmente.
- Se permite imprimir la información en formato amigable.

## 6. Seguridad
- Validación de parámetros en backend.
- Manejo de errores y mensajes claros en frontend.

## 7. Dependencias Frontend
- `qrcode.vue` para generación de QR.
- Bootstrap (opcional) para estilos.

## 8. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevos eRequest fácilmente.
- Los stored procedures pueden ser reutilizados por otros módulos.

## 9. Consideraciones
- El componente Vue es una página independiente, no usa tabs.
- El QR contiene: dependencia|año|num_acta|fecha_acta|contribuyente.
- El botón imprimir usa `window.print()` para impresión directa.

## 10. Ejemplo de Uso
1. Usuario ingresa el ID de multa y presiona Buscar.
2. Se muestran los datos, artículos y el QR.
3. Puede imprimir la página.

---
