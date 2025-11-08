# Documentación Técnica: Prescripción de Adeudos de Energía Eléctrica

## Descripción General
Este módulo permite la prescripción o condonación de adeudos de energía eléctrica asociados a locales de mercados. El proceso consiste en mover los adeudos seleccionados de la tabla de adeudos activos (`ta_11_adeudo_energ`) a la tabla de prescripciones/condonaciones (`ta_11_ade_ene_canc`), y viceversa.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js de página completa, sin tabs.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.

## API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "nombre_accion",
      "data": { ... },
      "user": { "id": 1 }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "success|error",
      "data": { ... },
      "message": "..."
    }
  }
  ```

### Acciones soportadas
- `buscar_local`: Busca un local y su id_energia.
- `listar_adeudos`: Lista adeudos activos de energía eléctrica.
- `listar_prescripcion`: Lista adeudos prescritos/condonados.
- `prescribir_adeudos`: Prescribe/condona los adeudos seleccionados.
- `quitar_prescripcion`: Quita la prescripción y restaura el adeudo.
- `catalogo_mercados`: Catálogo de mercados con energía eléctrica.
- `catalogo_secciones`: Catálogo de secciones.

## Stored Procedures
- **sp_prescribir_adeudo**: Inserta en `ta_11_ade_ene_canc` y elimina de `ta_11_adeudo_energ`.
- **sp_quitar_prescripcion**: Inserta en `ta_11_adeudo_energ` y elimina de `ta_11_ade_ene_canc`.

## Flujo de la Página Vue.js
1. Selección de mercado, sección, local, letra, bloque y tipo de movimiento.
2. Búsqueda del local y carga de adeudos y prescripciones.
3. Selección de adeudos a prescribir/condonar, captura de número de oficio.
4. Ejecución de prescripción (llamada a stored procedure por cada adeudo).
5. Visualización y posible reversión de prescripciones.

## Validaciones
- El número de oficio es obligatorio para prescribir/condonar.
- No se puede prescribir/condonar sin seleccionar al menos un adeudo.
- Solo se pueden quitar prescripciones seleccionando al menos una.

## Seguridad
- Todas las operaciones requieren usuario autenticado (user.id en eRequest).
- Las operaciones de prescripción y reversión quedan auditadas por usuario y fecha.

## Errores comunes
- Local no encontrado o dado de baja.
- Adeudo ya prescrito/condonado.
- Error de concurrencia en la base de datos.

## Integración
- El frontend Vue.js consume el endpoint `/api/execute` con la acción y los datos necesarios.
- El backend ejecuta el stored procedure correspondiente y retorna el resultado en eResponse.

## Ejemplo de llamada para prescribir adeudos
```json
{
  "eRequest": {
    "action": "prescribir_adeudos",
    "data": {
      "id_energia": 123,
      "adeudos": [
        { "id_energia": 123, "axo": 2023, "periodo": 5, "cve_consumo": "F", "cantidad": 100, "importe": 500.00 },
        ...
      ],
      "oficio": "ABC/2023/0001",
      "movimiento": "Prescripcion"
    },
    "user": { "id": 1 }
  }
}
```

## Ejemplo de llamada para quitar prescripción
```json
{
  "eRequest": {
    "action": "quitar_prescripcion",
    "data": {
      "id_energia": 123,
      "prescripciones": [
        { "id_cancelacion": 456, "id_energia": 123, "axo": 2023, "periodo": 5, "cve_consumo": "F", "cantidad": 100, "importe": 500.00 }
      ]
    },
    "user": { "id": 1 }
  }
}
```
