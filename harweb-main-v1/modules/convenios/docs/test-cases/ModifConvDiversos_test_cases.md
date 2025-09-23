# Casos de Prueba: ModifConvDiversos

## Caso 1: Modificar datos generales exitosamente
- **Entrada:**
  - action: modificarDatosGenerales
  - params: { id_conv_resto: 123, id_rec: 1, id_zona: 2, nombre: "JUAN PEREZ", calle: "AV. JUAREZ", num_exterior: 100, num_interior: 0, inciso: "A", metros: 50, observaciones: "ACTUALIZADO", telefono: "3312345678", correo: "juan@mail.com", oficio: "OF-2024", fechaoficio: "2024-06-01", nombrefirma: "JUAN PEREZ", tipo: 1, subtipo: 2, manzana: "MZ1", lote: 10, letra: "A", letras_ofi: "ZC1", folio_ofi: 123, alo_oficio: 2024, modulo: 5 }
- **Esperado:** status: success, message: Datos generales modificados correctamente

## Caso 2: Intentar modificar convenio bloqueado
- **Entrada:**
  - action: modificarDatosGenerales
  - params: { id_conv_resto: 124, ... }
- **Precondición:** El convenio 124 tiene bloqueo=1
- **Esperado:** status: error, message: No se puede modificar un convenio bloqueado

## Caso 3: Bloquear convenio sin permisos
- **Entrada:**
  - action: bloquearConvenio
  - params: { id_conv_resto: 125, observaciones: "Bloqueo" }
- **Precondición:** Usuario no tiene permisos de bloqueo
- **Esperado:** status: error, message: No tienes permiso para BLOQUEAR convenios

## Caso 4: Dar de baja convenio pagado
- **Entrada:**
  - action: darBajaConvenio
  - params: { id_conv_resto: 126, modulo: 5 }
- **Precondición:** El convenio 126 tiene vigencia='P'
- **Esperado:** status: success, message: Convenio dado de baja

## Caso 5: Buscar convenio inexistente
- **Entrada:**
  - action: buscarConvenio
  - params: { tipo: 99, subtipo: 99, letras_ofi: "XXX", folio_ofi: 999, alo_oficio: 2099 }
- **Esperado:** status: success, data: [], message: Convenio no encontrado
