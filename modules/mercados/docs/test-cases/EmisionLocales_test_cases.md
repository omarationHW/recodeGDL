# Casos de Prueba para Emisión de Recibos

## Caso 1: Emisión de Recibos Exitosa
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "emitirRecibos",
      "oficina": 2,
      "mercado": 15,
      "axo": 2024,
      "periodo": 6,
      "usuario_id": 1
    }
  }
  ```
- **Esperado**: Respuesta con lista de recibos generados (campos: id_local, local, nombre, descripcion_local, superficie, renta, subtotal, meses).

## Caso 2: Grabar Emisión con Locales ya Emitidos
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "grabarEmision",
      "oficina": 2,
      "mercado": 15,
      "axo": 2024,
      "periodo": 6,
      "usuario_id": 1
    }
  }
  ```
- **Esperado**: Respuesta con status 'ok', message 'Emisión grabada correctamente', y detalles por local (status 'insertado' o 'ya_existe').

## Caso 3: Facturación de Mercado Completa
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "facturacion",
      "oficina": 2,
      "mercado": 15,
      "axo": 2024,
      "periodo": 6,
      "solo_mercado": true
    }
  }
  ```
- **Esperado**: Respuesta con listado tabular de facturación (campos: id_local, nombre, descripcion_local, superficie, renta, subtotal).

## Caso 4: Error por Parámetros Inválidos
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "emitirRecibos",
      "oficina": null,
      "mercado": null,
      "axo": 2024,
      "periodo": 6,
      "usuario_id": 1
    }
  }
  ```
- **Esperado**: Respuesta con error indicando parámetros requeridos.

## Caso 5: Detalle de Local
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "detalleLocal",
      "id_local": 12345
    }
  }
  ```
- **Esperado**: Respuesta con todos los campos del local solicitado.
