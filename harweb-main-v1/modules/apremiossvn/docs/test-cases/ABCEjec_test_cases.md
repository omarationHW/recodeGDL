# Casos de Prueba para Catálogo de Ejecutores (ABCEjec)

## Caso 1: Alta de ejecutor exitoso
- **Entrada:**
  - action: create
  - params: {cve_eje: 200, ini_rfc: "TEST", fec_rfc: "1995-05-05", hom_rfc: "XYZ", nombre: "Test User", id_rec: 1, oficio: "OF-TEST", fecinic: "2024-01-01", fecterm: "2024-12-31"}
- **Esperado:**
  - eResponse.result[0] == 'OK'
  - El ejecutor aparece en la lista con vigencia 'A'.

## Caso 2: Alta duplicada (error)
- **Entrada:**
  - action: create
  - params: {cve_eje: 200, ini_rfc: "TEST", fec_rfc: "1995-05-05", hom_rfc: "XYZ", nombre: "Test User", id_rec: 1, oficio: "OF-TEST", fecinic: "2024-01-01", fecterm: "2024-12-31"}
- **Esperado:**
  - eResponse.result[0] == 'Ya existe ejecutor con ese número en la recaudadora'

## Caso 3: Modificación exitosa
- **Entrada:**
  - action: update
  - params: {cve_eje: 200, id_rec: 1, nombre: "Test User Modificado", oficio: "OF-TEST2", fecterm: "2025-12-31"}
- **Esperado:**
  - eResponse.result[0] == 'OK'
  - El ejecutor tiene los datos modificados.

## Caso 4: Baja y reactivación
- **Entrada:**
  - action: toggle_vigencia
  - params: {cve_eje: 200, id_rec: 1}
- **Esperado:**
  - eResponse.result[0] == 'Baja' (primera vez)
  - eResponse.result[0] == 'Reactivado' (segunda vez)

## Caso 5: Consulta de ejecutores
- **Entrada:**
  - action: list
  - params: {id_rec: 1}
- **Esperado:**
  - eResponse.result es un array de ejecutores con campos correctos

## Caso 6: Consulta individual
- **Entrada:**
  - action: get
  - params: {cve_eje: 200, id_rec: 1}
- **Esperado:**
  - eResponse.result[0].nombre == "Test User Modificado"
