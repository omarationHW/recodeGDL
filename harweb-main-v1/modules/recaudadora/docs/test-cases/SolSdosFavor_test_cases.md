# Casos de Prueba para Solicitud de Saldos a Favor

## Caso 1: Alta de Solicitud Exitosa
- **Entrada:** Todos los campos requeridos llenos, documentos seleccionados, status 'P', inconformidad y peticionario válidos.
- **Acción:** createSolicitud
- **Resultado esperado:** success=true, folio generado, status='P', registro en base de datos.

## Caso 2: Alta con Campos Faltantes
- **Entrada:** Falta campo 'solicitante'.
- **Acción:** createSolicitud
- **Resultado esperado:** success=false, message='El campo solicitante es obligatorio.'

## Caso 3: Edición Exitosa
- **Entrada:** id_solic válido, campos modificados.
- **Acción:** updateSolicitud
- **Resultado esperado:** success=true, datos actualizados en base de datos.

## Caso 4: Cancelación Exitosa
- **Entrada:** id_solic válido, status actual 'P'.
- **Acción:** cancelSolicitud
- **Resultado esperado:** success=true, status='C', no editable.

## Caso 5: Listado de Solicitudes
- **Entrada:** action=listSolicitudes, sin filtro.
- **Acción:** listSolicitudes
- **Resultado esperado:** success=true, data es array de solicitudes ordenadas por folio.

## Caso 6: Listado Filtrado por Status
- **Entrada:** action=listSolicitudes, params.status='C'.
- **Acción:** listSolicitudes
- **Resultado esperado:** success=true, data solo solicitudes canceladas.

## Caso 7: Catálogos
- **Entrada:** action=getDoctosCatalog, getPeticionariosCatalog, getInconformidadesCatalog
- **Resultado esperado:** success=true, data es array de catálogos respectivos.
