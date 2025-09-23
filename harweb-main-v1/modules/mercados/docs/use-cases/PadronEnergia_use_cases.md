# Casos de Uso - PadronEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón de Energía para un Mercado

**Descripción:** El usuario desea consultar el padrón de energía eléctrica para un mercado específico de una recaudadora.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo de energía.

**Pasos a seguir:**
1. El usuario accede a la página 'Padrón de Energía Eléctrica'.
2. Selecciona una recaudadora de la lista.
3. Selecciona un mercado de la lista filtrada por la recaudadora.
4. Hace clic en 'Buscar'.
5. El sistema muestra la tabla con los locales y datos de energía.

**Resultado esperado:**
Se muestra el padrón de energía eléctrica correspondiente al mercado seleccionado.

**Datos de prueba:**
{ "id_rec": 2, "num_mercado_nvo": 10 }

---

## Caso de Uso 2: Exportar Padrón de Energía a Excel

**Descripción:** El usuario desea exportar el padrón de energía eléctrica a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
1. El usuario hace clic en 'Exportar Excel'.
2. El sistema genera el archivo y muestra un enlace de descarga.

**Resultado esperado:**
El usuario puede descargar el archivo Excel con los datos del padrón.

**Datos de prueba:**
{ "id_rec": 3, "num_mercado_nvo": 7 }

---

## Caso de Uso 3: Imprimir Padrón de Energía en PDF

**Descripción:** El usuario desea imprimir el padrón de energía eléctrica en formato PDF.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
1. El usuario hace clic en 'Imprimir PDF'.
2. El sistema genera el PDF y lo muestra en una nueva ventana.

**Resultado esperado:**
El usuario visualiza el PDF listo para imprimir.

**Datos de prueba:**
{ "id_rec": 1, "num_mercado_nvo": 5 }

---

