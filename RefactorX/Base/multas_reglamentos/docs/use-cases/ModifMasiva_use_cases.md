# Casos de Uso - ModifMasiva

**Categoría:** Form

## Caso de Uso 1: Modificación masiva de requerimientos de Predial

**Descripción:** El usuario desea marcar como practicados todos los requerimientos de predial de la recaudadora 1, folios del 1000 al 1100, con fecha de práctica 2024-06-01.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos para modificar requerimientos. Los folios deben existir y estar vigentes.

**Pasos a seguir:**
[
  "El usuario accede a la página de Modificación Masiva.",
  "Selecciona 'Predial' como tipo de requerimiento.",
  "Ingresa recaudadora 1, folio inicial 1000, folio final 1100.",
  "Selecciona la fecha de práctica 2024-06-01.",
  "Selecciona la acción 'Marcar como Practicado'.",
  "Presiona 'Ejecutar'.",
  "El sistema envía la petición a /api/execute con los parámetros.",
  "El backend ejecuta el stored procedure correspondiente.",
  "El sistema muestra el número de folios modificados."
]

**Resultado esperado:**
Todos los folios de predial en el rango indicado quedan marcados como practicados con la fecha seleccionada.

**Datos de prueba:**
{
  "action": "modificar_predial",
  "params": {
    "recaud": 1,
    "folio_ini": 1000,
    "folio_fin": 1100,
    "fecha": "2024-06-01"
  },
  "user": "admin"
}

---

## Caso de Uso 2: Cancelación masiva de requerimientos de Multas

**Descripción:** El usuario desea cancelar todos los requerimientos de multas de la recaudadora 2, folios del 2000 al 2100, con fecha de cancelación 2024-06-02.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos para cancelar requerimientos. Los folios deben estar vigentes y no diligenciados.

**Pasos a seguir:**
[
  "El usuario accede a la página de Modificación Masiva.",
  "Selecciona 'Multa' como tipo de requerimiento.",
  "Ingresa recaudadora 2, folio inicial 2000, folio final 2100.",
  "Selecciona la fecha de cancelación 2024-06-02.",
  "Selecciona la acción 'Cancelar'.",
  "Presiona 'Ejecutar'.",
  "El sistema envía la petición a /api/execute con los parámetros.",
  "El backend ejecuta el stored procedure correspondiente.",
  "El sistema muestra el número de folios cancelados."
]

**Resultado esperado:**
Todos los folios de multas en el rango indicado quedan cancelados con la fecha seleccionada.

**Datos de prueba:**
{
  "action": "cancelar_multa",
  "params": {
    "recaud": 2,
    "folio_ini": 2000,
    "folio_fin": 2100,
    "fecha": "2024-06-02"
  },
  "user": "admin"
}

---

## Caso de Uso 3: Modificación masiva de requerimientos de Licencias

**Descripción:** El usuario desea marcar como practicados todos los requerimientos de licencias de la recaudadora 3, folios del 3000 al 3050, con fecha de práctica 2024-06-03.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos para modificar requerimientos. Los folios deben existir y estar vigentes.

**Pasos a seguir:**
[
  "El usuario accede a la página de Modificación Masiva.",
  "Selecciona 'Licencia' como tipo de requerimiento.",
  "Ingresa recaudadora 3, folio inicial 3000, folio final 3050.",
  "Selecciona la fecha de práctica 2024-06-03.",
  "Selecciona la acción 'Marcar como Practicado'.",
  "Presiona 'Ejecutar'.",
  "El sistema envía la petición a /api/execute con los parámetros.",
  "El backend ejecuta el stored procedure correspondiente.",
  "El sistema muestra el número de folios modificados."
]

**Resultado esperado:**
Todos los folios de licencias en el rango indicado quedan marcados como practicados con la fecha seleccionada.

**Datos de prueba:**
{
  "action": "modificar_licencia",
  "params": {
    "recaud": 3,
    "folio_ini": 3000,
    "folio_fin": 3050,
    "fecha": "2024-06-03"
  },
  "user": "admin"
}

---

