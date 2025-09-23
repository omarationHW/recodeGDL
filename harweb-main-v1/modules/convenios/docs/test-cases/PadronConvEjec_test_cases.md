# Casos de Prueba PadronConvEjec

## Caso 1: Consulta básica
- **Descripción:** Consulta de convenios con filtros mínimos.
- **Entrada:** tipo=1, subtipo=1, recaudadora=1, vigencia='A', ejecutor=6, anio_ini=2013, anio_fin=2015
- **Esperado:** Lista de convenios correspondiente.

## Caso 2: Exportación Excel
- **Descripción:** Exportar convenios filtrados a Excel.
- **Entrada:** tipo=3, subtipo=000, recaudadora=000, vigencia='P', ejecutor=000, anio_ini=2010, anio_fin=2020
- **Esperado:** Archivo Excel generado y descargado.

## Caso 3: Sin resultados
- **Descripción:** Consulta con filtros sin coincidencias.
- **Entrada:** tipo=99, subtipo=000, recaudadora=000, vigencia='A', ejecutor=000, anio_ini=2050, anio_fin=2051
- **Esperado:** Mensaje 'No hay resultados.'

## Caso 4: Error de parámetros
- **Descripción:** Enviar parámetros inválidos (ejemplo: año inicio mayor que año fin).
- **Entrada:** tipo=1, subtipo=1, recaudadora=1, vigencia='A', ejecutor=6, anio_ini=2025, anio_fin=2020
- **Esperado:** Mensaje de error indicando parámetros inválidos.

## Caso 5: Seguridad
- **Descripción:** Intentar acceder sin autenticación.
- **Entrada:** Sin token de autenticación.
- **Esperado:** Error 401 Unauthorized.
