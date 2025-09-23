# Casos de Prueba para SdosFavor_CtrlExp

## 1. Consulta de folios por estatus
- **Entrada:** action=searchFolios, params={"status":"P"}
- **Esperado:** Lista de folios con status 'P', sin error.

## 2. Asignación masiva de folios
- **Entrada:** action=assignFolios, params={"folios":[1001,1002,1003],"new_status":"AS"}
- **Esperado:** Respuesta success, los folios cambian a status 'AS'.

## 3. Conteo de folios por estatus
- **Entrada:** action=getTotalFolios, params={"status":"AS"}
- **Esperado:** Campo data con el número total de folios con status 'AS'.

## 4. Consulta de todos los folios (sin filtro)
- **Entrada:** action=searchFolios, params={}
- **Esperado:** Lista completa de folios.

## 5. Error por falta de folios en asignación
- **Entrada:** action=assignFolios, params={"folios":[],"new_status":"AS"}
- **Esperado:** status=error, message='No folios selected'.

## 6. Error por acción no soportada
- **Entrada:** action=unknownAction, params={}
- **Esperado:** status=error, message='Acción no soportada'.
