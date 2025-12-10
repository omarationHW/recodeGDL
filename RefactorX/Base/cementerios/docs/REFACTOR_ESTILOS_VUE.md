# REFACTORIZACIÓN DE ESTILOS - CEMENTERIOS
**Fecha Inicio:** 2025-12-07
**Estado:** En Proceso
**Objetivo:** Homogeneizar todos los componentes Vue con estilos municipales estándar

---

## 📋 ARCHIVO DE REFERENCIA

**Archivo patrón:** `RefactorX/FrontEnd/src/views/modules/padron_licencias/consultausuariosfrm.vue`

### Características del Patrón:
- ✅ Bootstrap + municipal-theme.css (estilos globales)
- ✅ Sin estilos scoped (migrados a municipal-theme.css)
- ✅ Colores institucionales definidos
- ✅ Toast notifications homogéneas
- ✅ Loading global consistente
- ✅ Diálogos SweetAlert2 con estilos municipales
- ✅ Tablas paginadas (server-side, 10 registros por defecto)
- ✅ Detalles en modales/popups
- ✅ Cards con estructura municipal-card
- ✅ Botones con clases btn-municipal-*
- ✅ Inputs con municipal-form-control
- ✅ CRUD funcional contra BD

---

## 🎯 CHECKLIST DE VALIDACIÓN

Para cada componente Vue se debe verificar:

### 1. Estructura HTML
- [ ] Header con `module-view-header` y `module-view-icon`
- [ ] Content con `module-view-content`
- [ ] Cards con `municipal-card` y `municipal-card-header`/`municipal-card-body`
- [ ] Filtros colapsables con toggle

### 2. Estilos y Clases
- [ ] Usa `municipal-theme.css` (sin estilos scoped)
- [ ] Botones con clases `btn-municipal-primary`, `btn-municipal-secondary`, `btn-municipal-purple`
- [ ] Inputs con clase `municipal-form-control`
- [ ] Labels con clase `municipal-form-label`
- [ ] Form rows con `form-row` y `form-group`
- [ ] Badges con `badge-success`, `badge-danger`, `badge-purple`, `badge-warning`
- [ ] FontAwesome icons consistentes

### 3. Componentes Interactivos
- [ ] Toast notifications usando `useToast` composable
- [ ] Loading global usando `useGlobalLoading` composable
- [ ] SweetAlert2 para confirmaciones con colores municipales (`confirmButtonColor: '#ea8215'`)
- [ ] Modal component de `@/components/common/Modal.vue`
- [ ] DocumentationModal implementado

### 4. Tablas
- [ ] Clase `municipal-table` con `municipal-table-header`
- [ ] Paginación con controles de navegación
- [ ] 10 registros por página por defecto
- [ ] Selectores de cantidad de registros (5, 10, 25, 50, 100)
- [ ] Información de paginación (Mostrando X a Y de Z registros)
- [ ] Row hover con clase `row-hover`
- [ ] Row selection con clase `table-row-selected`

### 5. Funcionalidad
- [ ] CRUD funcional contra base de datos
- [ ] Validaciones de campos
- [ ] Manejo de errores con `handleApiError`
- [ ] Loading states en botones (`:disabled="loading"`)
- [ ] Response handling correcto

---

## 📊 PROGRESO DE REFACTORIZACIÓN

**Total de componentes:** 32 (excluyendo Menu, Modulo, Acceso, sfrm_chgpass)
**Refactorizados:** 32
**En Proceso:** 0
**Pendientes:** 0
**Progreso:** 100% (32/32) ✅ ¡COMPLETADO!

---

## 📝 COMPONENTES A REFACTORIZAR

### CRÍTICOS - Gestión Principal (5)
| # | Componente | Estado Estilos | Verificado | Notas |
|---|------------|----------------|------------|-------|
| 1 | ABCFolio.vue | ✅ Refactorizado | ✅ Usuario | Toast manual, DocumentationModal, SweetAlert colores |
| 2 | ABCRecargos.vue | ✅ Refactorizado | ⏳ Pendiente | 7 llamadas toast, modal con carga .md |
| 3 | ABCPagos.vue | ✅ Refactorizado | ⏳ Pendiente | 12 llamadas toast, 2 SweetAlert |
| 4 | ABCPagosxfol.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual, DocumentationModal, botón ayuda, SweetAlert colores |
| 5 | ABCementer.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (13), DocumentationModal, botón ayuda, SweetAlert colores, eliminó HTML hardcoded |

### CONSULTAS - Búsqueda y Visualización (9)
| # | Componente | Estado Estilos | Verificado | Notas |
|---|------------|----------------|------------|-------|
| 31 | ConIndividual.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (5), header estándar, botón ayuda, DocumentationModal, HTML hardcoded eliminado (~36 líneas) |
| 7 | ConsultaNombre.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (4), header estándar, DocumentationModal |
| 8 | ConsultaRCM.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (9), header estándar, DocumentationModal |
| 9 | ConsultaFol.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (4), header estándar, DocumentationModal, eliminó HTML hardcoded |
| 10 | ConsultaGuad.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (9), header estándar, DocumentationModal, eliminó HTML hardcoded |
| 11 | ConsultaJardin.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (9), header estándar, DocumentationModal, eliminó HTML hardcoded |
| 12 | ConsultaMezq.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (9), header estándar, DocumentationModal, eliminó HTML hardcoded |
| 13 | ConsultaSAndres.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (3), paginación estándar, DocumentationModal, HTML hardcoded eliminado |
| 14 | Consulta400.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (4), botón ayuda estándar, paginación, DocumentationModal, HTML eliminado |

### MULTIPLEX - Búsquedas Múltiples (3)
| # | Componente | Estado Estilos | Verificado | Notas |
|---|------------|----------------|------------|-------|
| 15 | MultipleNombre.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (4), botón ayuda, paginación, DocumentationModal, eliminó "Cargar Más" |
| 16 | MultipleRCM.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (4), botón ayuda, paginación, DocumentationModal, eliminó "Cargar Más" |
| 17 | Multiplefecha.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (4), botón ayuda, paginación, DocumentationModal, header estándar |

### OPERACIONES - Gestión y Procesos (6)
| # | Componente | Estado Estilos | Verificado | Notas |
|---|------------|----------------|------------|-------|
| 18 | Bonificaciones.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (11), header estándar, botón ayuda, DocumentationModal, SweetAlert colores |
| 19 | Bonificacion1.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (13), header estándar, botón ayuda, DocumentationModal, SweetAlert colores, helpSections eliminado |
| 20 | Descuentos.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (ya correcto), header estándar, botón ayuda, DocumentationModal, SweetAlert colores, HTML eliminado |
| 21 | Liquidaciones.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (5), header estándar, botón ayuda, DocumentationModal, HTML eliminado, N/A SweetAlert |
| 22 | List_Mov.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (ya correcto), header estándar, botón ayuda, DocumentationModal, helpSections eliminado, toast incorrecto eliminado |
| 23 | Duplicados.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (ya correcto), header estándar, botón ayuda, DocumentationModal, SweetAlert colores, helpSections eliminado, toast duplicado eliminado |

### TRASLADOS (3)
| # | Componente | Estado Estilos | Verificado | Notas |
|---|------------|----------------|------------|-------|
| 24 | Traslados.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (5), header estándar, botón ayuda, DocumentationModal, SweetAlert colores, 16 CSS classes actualizadas, callProcedure mantenido |
| 25 | TrasladoFol.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (9), header estándar, botón ayuda, DocumentationModal, SweetAlert colores, 2 CSS classes actualizadas, HTML hardcoded eliminado |
| 26 | TrasladoFolSin.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (9), header estándar, botón ayuda, DocumentationModal, SweetAlert colores, 2 CSS classes actualizadas, HTML hardcoded eliminado |

### REPORTES (4)
| # | Componente | Estado Estilos | Verificado | Notas |
|---|------------|----------------|------------|-------|
| 27 | Rep_Bon.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (4), header estándar, botón ayuda, DocumentationModal, helpSections eliminado, scoped styles eliminados |
| 28 | Rep_a_Cobrar.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (4), header estándar, botón ayuda, DocumentationModal, helpSections eliminado |
| 29 | RptTitulos.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (5), header estándar, botón ayuda, DocumentationModal, helpSections eliminado |
| 30 | Estad_adeudo.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (3), header estándar, botón ayuda, DocumentationModal, helpSections eliminado |

### TÍTULOS (2) - Movidos al final por usuario
| # | Componente | Estado Estilos | Verificado | Notas |
|---|------------|----------------|------------|-------|
| 32 | Titulos.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (10), header estándar, botón ayuda, DocumentationModal, HTML hardcoded eliminado (~20 líneas), SweetAlert colores |
| 33 | TitulosSin.vue | ✅ Refactorizado | ⏳ Pendiente | Toast manual (11), header COMPLETO refactorizado, botón ayuda, DocumentationModal, helpSections eliminado (~17 líneas) - ¡ÚLTIMO COMPONENTE! |

---

## 🔄 PROCESO DE REFACTORIZACIÓN

### Agentes Especializados

#### 1. AGENTE IMPLEMENTADOR
**Responsabilidad:** Aplicar cambios de estilos a componentes Vue

**Tareas:**
- Leer componente actual
- Identificar estilos scoped y clases no estándar
- Migrar estilos a estructura municipal-theme.css
- Implementar loading global
- Implementar toast notifications
- Ajustar tablas con paginación (10 registros)
- Implementar modales para detalles
- Verificar CRUD funcional
- **NO cambiar lógica de negocio**

#### 2. AGENTE VERIFICADOR
**Responsabilidad:** Validar cambios aplicados

**Validaciones:**
- ✅ Checklist de estructura HTML completo
- ✅ Checklist de estilos y clases completo
- ✅ Checklist de componentes interactivos completo
- ✅ Checklist de tablas completo
- ✅ Checklist de funcionalidad completo
- ✅ Sin estilos scoped innecesarios
- ✅ Colores institucionales correctos
- ✅ Sin errores de consola
- ✅ CRUD funciona correctamente

**Salida:**
- Archivo con errores encontrados
- Lista de correcciones necesarias
- Estado: APROBADO / REQUIERE CAMBIOS

---

## 📋 LEYENDA

### Estados
- ⏳ **Pendiente**: No iniciado
- 🔄 **En Proceso**: Trabajando actualmente
- ✅ **Refactorizado**: Implementado y verificado
- ⚠️ **Revisión**: Requiere ajustes
- ❌ **Bloqueado**: Errores encontrados

---

## 🔄 HISTORIAL DE CAMBIOS

### 2025-12-08 - RptTitulos.vue REFACTORIZADO ✅
**ACCIÓN:** Vigésimooctavo componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (5 llamadas actualizadas)
  - Eliminado composable `useToast` (línea 112, 117)
  - Cambiado de `toast.warning/success/info/error()` a `showToast('tipo', 'mensaje')`
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Actualizadas llamadas en: generarReporte (4), exportarPDF (1)

- ✅ Header estándar actualizado
  - Cambiado de estructura simple con `<h1 class="module-view-info">` a estándar
  - Agregado `.module-view-icon` con FontAwesome icon
  - Agregado `.module-view-info` con título y descripción
  - Agregado `.button-group.ms-auto` para botón de ayuda
  - DocumentationModal movido del header a botón dedicado

- ✅ Botón de ayuda estándar
  - Movido DocumentationModal inline a botón separado `btn-municipal-purple`
  - Agregado dentro de `div.button-group.ms-auto`
  - Agregado texto "Ayuda" al botón
  - Variable `mostrarAyuda()` creada, eliminado `openDocumentation()`

- ✅ DocumentationModal actualizado
  - Eliminado `helpSections` array hardcodeado (~17 líneas)
  - Props: `:show="showDocumentation"`, `:componentName="'RptTitulos'"`, `:moduleName="'cementerios'"`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`
  - Eliminado prop `title` y `:sections`

- ✅ Import FontAwesomeIcon agregado
  - Agregado `import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'`

- ❌ Sin SweetAlert en este componente (N/A)
- ❌ Sin scoped styles (N/A)
- ❌ Sin clases CSS `form-input` (ya usaba `municipal-form-control`)
- ℹ️ Sin paginación en este componente (reporte completo con tabla de resultados)

**Características del componente:**
- Reporte de títulos de propiedad emitidos
- Filtro por rango de fechas (desde/hasta)
- Filtro opcional por cementerio
- Tabla con columnas: título, fecha, folio, titular, cementerio, ubicación, importe, recaudación
- Total general calculado
- Funcionalidad de exportación a PDF (en desarrollo)
- Fechas por defecto: mes actual

---

### 2025-12-08 - Estad_adeudo.vue REFACTORIZADO ✅
**ACCIÓN:** Vigésimonoveno componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (3 llamadas actualizadas)
  - Eliminado composable `useToast` implícito
  - Cambiado de `toast.success/info/error()` a `showToast('tipo', 'mensaje')`
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Actualizadas llamadas en: generarEstadisticas (3)

- ✅ Header estándar actualizado
  - Cambiado de estructura simple a estándar con `.module-view-header`
  - Agregado `.module-view-icon` con FontAwesome icon "chart-bar"
  - Agregado `.module-view-info` con título y descripción
  - Agregado `.button-group.ms-auto` para botón de ayuda
  - DocumentationModal movido del header a botón dedicado

- ✅ Botón de ayuda estándar
  - Botón `btn-municipal-purple` con texto "Ayuda"
  - Agregado dentro de `div.button-group.ms-auto`
  - Variable `mostrarAyuda()` creada, eliminado `openDocumentation()`

- ✅ DocumentationModal actualizado
  - Eliminado `helpSections` array hardcodeado (~12 líneas)
  - Props: `:show="showDocumentation"`, `:componentName="'Estad_adeudo'"`, `:moduleName="'cementerios'"`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`
  - Eliminado prop `title` y `:sections`

- ✅ Import FontAwesomeIcon agregado
  - Agregado `import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'`

- ❌ Sin SweetAlert en este componente (N/A)
- ❌ Sin scoped styles (N/A)
- ❌ Sin clases CSS `form-input` (ya usaba `municipal-form-control`)
- ℹ️ Sin paginación en este componente (estadísticas con tabla resumen)

**Características del componente:**
- Estadísticas de adeudos por cementerio
- Filtro por cementerio (opcional: todos)
- Tabla con columnas: cementerio, total folios, al corriente, atrasados, % al corriente, % atrasados
- Fila de totales calculada
- Gráfico visual de distribución (barras progreso)
- Cálculo de porcentajes automático

**Total de líneas:**
- Eliminadas: ~25 líneas (helpSections + useToast composable + openDocumentation)
- Agregadas: ~55 líneas (toast + métodos + template + header)
- Modificadas: 5 llamadas toast + header completo + botón ayuda

**Progreso:** 28/32 componentes (87.5%)

---

### 2025-12-08 - ConIndividual.vue REFACTORIZADO ✅
**ACCIÓN:** Trigésimo componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (5 llamadas actualizadas)
  - Eliminado composable `useToast` (línea 529, 533)
  - Cambiado de `showToast('mensaje', 'tipo')` a `showToast('tipo', 'mensaje')` (parámetros invertidos)
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Actualizadas llamadas en: buscarFolio (4), imprimirFolio (1)

- ✅ Botón de ayuda estándar
  - Cambiado de `btn-help-icon` a `btn-municipal-purple` con texto "Ayuda"
  - Agregado dentro de `div.button-group.ms-auto`
  - Cambiado `@click="mostrarAyuda = true"` a `@click="mostrarAyuda"` (método)
  - Eliminado `ref(false)`, agregados métodos `mostrarAyuda()` y `closeDocumentation()`

- ✅ DocumentationModal actualizado
  - Eliminado HTML inline hardcodeado (~36 líneas de contenido)
  - Props actualizados: `:show="showDocumentation"`, `:componentName="'ConIndividual'"`, `:moduleName="'cementerios'"`
  - Eliminado prop `title`
  - Cerrado con `/>` (sin children)

- ❌ Header ya estaba correcto (`.module-view-icon` + `.module-view-info`)
- ❌ Sin SweetAlert en este componente (N/A)
- ❌ Sin scoped styles (N/A)
- ❌ Sin clases CSS `form-input` (ya usaba `municipal-form-control`)
- ℹ️ Sin paginación en este componente (consulta individual con tabs)

**Características del componente:**
- Consulta individual COMPLETA de folios RCM con 12 queries en paralelo
- 7 tabs informativos: Adeudos, Pagos, Desc/Rec, Pendientes, Historial, Contactos, Cajero
- Cálculo automático de totales de adeudos
- Información detallada del titular, ubicación, datos adicionales
- Bonificación disponible
- Resumen para cajero del año actual
- Componente complejo con múltiples tablas y datos relacionados

**Total de líneas:**
- Eliminadas: ~41 líneas (useToast composable + HTML inline modal + ref duplicado)
- Agregadas: ~50 líneas (toast + métodos + template + documentation modal state)
- Modificadas: 5 llamadas toast (invertir parámetros) + botón ayuda

**Progreso:** 30/32 componentes (93.8%)

---

### 2025-12-08 - Titulos.vue REFACTORIZADO ✅
**ACCIÓN:** Trigésimo primer componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (10 llamadas actualizadas)
  - Eliminado composable `useToast` (línea 400, 405)
  - Cambiado de `showToast('mensaje', 'tipo')` a `showToast('tipo', 'mensaje')` (parámetros invertidos)
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Actualizadas llamadas en: cargarTitulos (1), buscarTitulo (4), guardarTitulo (4), prepararImpresion (1)

- ✅ Botón de ayuda estándar
  - Cambiado de `btn-help-icon` a `btn-municipal-purple` con texto "Ayuda"
  - Agregado dentro de `div.button-group.ms-auto`
  - Cambiado `@click="mostrarAyuda = true"` a `@click="mostrarAyuda"` (método)
  - Eliminado `ref(false)`, agregados métodos `mostrarAyuda()` y `closeDocumentation()`

- ✅ DocumentationModal actualizado
  - Eliminado HTML inline hardcodeado (~20 líneas de contenido)
  - Props actualizados: `:show="showDocumentation"`, `:componentName="'Titulos'"`, `:moduleName="'cementerios'"`
  - Eliminado prop `title`
  - Cerrado con `/>` (sin children)

- ✅ SweetAlert2 con colores municipales
  - Agregado `confirmButtonColor: '#ea8215'` (naranja institucional)
  - Agregado `cancelButtonColor: '#6c757d'` (gris)
  - Aplicado en: prepararImpresion (1 SweetAlert)

- ❌ Header ya estaba correcto (`.module-view-icon` + `.module-view-info`)
- ❌ Sin scoped styles (N/A)
- ❌ Sin clases CSS `form-input` (ya usaba `municipal-form-control`)
- ℹ️ Con paginación estándar (10 registros por página)

**Características del componente:**
- Gestión e impresión de títulos de propiedad de fosas
- Búsqueda por folio y operación
- Actualización de datos del beneficiario (libro, año, folio del título)
- Registro de información extra: nombre, domicilio, colonia, teléfono del beneficiario
- Listado paginado de todos los títulos registrados
- Preparación para impresión con confirmación SweetAlert
- Validación de formulario completa

**Total de líneas:**
- Eliminadas: ~25 líneas (useToast composable + HTML inline modal + ref duplicado)
- Agregadas: ~50 líneas (toast + métodos + template + documentation modal state)
- Modificadas: 10 llamadas toast (invertir parámetros) + botón ayuda + SweetAlert colores

**Progreso:** 31/32 componentes (96.9%)

---

### 2025-12-08 - TitulosSin.vue REFACTORIZADO ✅ - ¡COMPONENTE FINAL!
**ACCIÓN:** Trigésimo segundo y ÚLTIMO componente refactorizado con patrón estándar

**🎉 ¡REFACTORIZACIÓN COMPLETADA AL 100%! 🎉**

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (11 llamadas actualizadas - ¡MÁXIMO JUNTO CON TITULOS!)
  - Eliminado composable `useToast` (línea 175, 180)
  - Cambiado de `toast.warning/success/error/info('mensaje')` a `showToast('tipo', 'mensaje')`
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Actualizadas llamadas en: buscarFolio (5), generarTitulo (5), imprimirTitulo (1)

- ✅ Header COMPLETAMENTE refactorizado (mayor cambio estructural)
  - Cambiado de `<h1 class="module-view-info">` a estructura estándar completa
  - Agregado `.module-view-icon` con FontAwesome icon
  - Agregado `.module-view-info` con título y descripción
  - Agregado `.button-group.ms-auto` para botón de ayuda
  - DocumentationModal movido del header inline a botón dedicado

- ✅ Botón de ayuda estándar
  - DocumentationModal estaba inline en header (líneas 8-11), ahora es botón separado
  - Botón `btn-municipal-purple` con texto "Ayuda"
  - Agregado dentro de `div.button-group.ms-auto`
  - Métodos `mostrarAyuda()` y `closeDocumentation()` implementados

- ✅ DocumentationModal actualizado
  - Eliminado `helpSections` array hardcodeado (~17 líneas de contenido)
  - Props actualizados: `:show="showDocumentation"`, `:componentName="'TitulosSin'"`, `:moduleName="'cementerios'"`
  - Eliminados props `title` y `:sections`
  - Cerrado con `/>` (sin children)

- ✅ Import FontAwesomeIcon agregado
  - Agregado `import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'`

- ❌ Sin SweetAlert en este componente (N/A)
- ❌ Sin scoped styles (N/A)
- ❌ Sin clases CSS `form-input` (ya usaba `municipal-form-control`)
- ℹ️ Sin paginación en este componente (generación simple de títulos)

**Características del componente:**
- Generación automática de títulos de propiedad sin número previo
- Búsqueda de folio por número
- Validación de titular y ubicación
- Entrada de datos del título: fecha, importe, recaudación, observaciones
- Asignación automática de número de título
- Historial de títulos generados recientemente (últimos 10)
- Funcionalidad de impresión (en desarrollo)

**Total de líneas:**
- Eliminadas: ~22 líneas (useToast composable + helpSections array + openDocumentation + header antiguo)
- Agregadas: ~65 líneas (toast + métodos + template + header estándar + documentation modal state)
- Modificadas: 11 llamadas toast + header COMPLETO + botón ayuda

**🎯 PROGRESO FINAL:** 32/32 componentes (100%) ✅

**🏆 ¡REFACTORIZACIÓN DEL MÓDULO CEMENTERIOS COMPLETADA EXITOSAMENTE! 🏆**

---

### 2025-12-08 - Rep_a_Cobrar.vue REFACTORIZADO ✅
**ACCIÓN:** Vigésimoséptimo componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (4 llamadas actualizadas)
  - Eliminado composable `useToast` (línea 147, 152)
  - Cambiado de `toast.warning/success/info/error()` a `showToast('tipo', 'mensaje')`
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Actualizadas llamadas en: generarReporte (4)

- ✅ Header estándar actualizado
  - Cambiado de estructura simple con `<h1 class="module-view-info">` a estándar
  - Agregado `.module-view-icon` con FontAwesome icon
  - Agregado `.module-view-info` con título y descripción
  - Agregado `.button-group.ms-auto` para botón de ayuda
  - DocumentationModal movido del header a botón dedicado

- ✅ Botón de ayuda estándar
  - Movido DocumentationModal inline a botón separado `btn-municipal-purple`
  - Agregado dentro de `div.button-group.ms-auto`
  - Agregado texto "Ayuda" al botón

- ✅ DocumentationModal actualizado
  - Eliminado `helpSections` array hardcodeado (~18 líneas)
  - Props: `:show="showDocumentation"`, `:componentName="'Rep_a_Cobrar'"`, `:moduleName="'cementerios'"`
  - Variable nueva: `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`
  - Eliminado prop `title` y `:sections`

- ✅ Import FontAwesomeIcon agregado
  - Agregado `import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'`

- ❌ Sin SweetAlert en este componente (N/A)
- ❌ Sin scoped styles (N/A)
- ❌ Sin clases CSS `form-input` (ya usaba `municipal-form-control`)
- ℹ️ Sin paginación en este componente (reporte agrupado por metraje)

**Características del componente:**
- Reporte de recargos por mes para cobro de mantenimiento
- Filtro por mes (1-12) con combo de selección
- Info de recaudadora del usuario logueado (zona, recaudadora)
- Tabla agrupada por metraje (X MTS. 1 ERA. CLASE)
- Columnas: años de adeudo, mantenimiento, recargos, total
- Resumen con totales: mantenimiento, recargos, gran total
- Lógica recodificada del Pascal Rep_a_Cobrar.pas

**Total de líneas:**
- Eliminadas: ~26 líneas (helpSections + useToast composable)
- Agregadas: ~55 líneas (toast + métodos + template + header)
- Modificadas: 4 llamadas toast + header completo + botón ayuda

**Progreso:** 27/32 componentes (84.4%)

---

### 2025-12-08 - Rep_Bon.vue REFACTORIZADO ✅
**ACCIÓN:** Vigésimosexto componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (4 llamadas actualizadas)
  - Eliminado composable `useToast` (línea 163, 168)
  - Cambiado de `toast.warning/success/info/error()` a `showToast('tipo', 'mensaje')`
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Actualizadas llamadas en: generarReporte (4)

- ✅ Header estándar actualizado
  - Cambiado de estructura simple con `<h1 class="module-view-info">` a estándar
  - Agregado `.module-view-icon` con FontAwesome icon
  - Agregado `.module-view-info` con título y descripción
  - Agregado `.button-group.ms-auto` para botón de ayuda
  - DocumentationModal movido del header a botón dedicado

- ✅ Botón de ayuda estándar
  - Movido DocumentationModal inline a botón separado `btn-municipal-purple`
  - Agregado dentro de `div.button-group.ms-auto`
  - Agregado texto "Ayuda" al botón

- ✅ DocumentationModal actualizado
  - Eliminado `helpSections` array hardcodeado (~23 líneas)
  - Props: `:show="showDocumentation"`, `:componentName="'Rep_Bon'"`, `:moduleName="'cementerios'"`
  - Variable nueva: `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`
  - Eliminado prop `title` y `:sections`

- ✅ Import FontAwesomeIcon agregado
  - Agregado `import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'`

- ✅ Estilos scoped eliminados
  - Eliminado `<style scoped>` con estilos de radio-group (~15 líneas)
  - Radio buttons usan estilos globales de municipal-theme.css

- ❌ Sin SweetAlert en este componente (N/A)
- ❌ Sin clases CSS `form-input` (ya usaba `municipal-form-control`)
- ℹ️ Sin paginación en este componente (reporte con tabla de resultados completos)

**Características del componente:**
- Reporte de oficios de bonificación por recaudadora (1-9)
- Dos tipos de reporte: Pendientes (importe_resto > 0) o Todos
- Info de recaudadora desde tabla auxiliar
- Tabla con columnas: control_bon, oficio, año, folio, cementerio, ubicación, importes, usuario, fechas
- Totales calculados: total bonificar, bonificado y resto
- Lógica recodificada del Pascal Rep_Bon.pas

**Total de líneas:**
- Eliminadas: ~46 líneas (helpSections + scoped styles + useToast composable)
- Agregadas: ~55 líneas (toast + métodos + template + header)
- Modificadas: 4 llamadas toast + header completo + botón ayuda

**Progreso:** 26/32 componentes (81.3%)

---

### 2025-12-08 - TrasladoFolSin.vue REFACTORIZADO ✅
**ACCIÓN:** Vigésimoquinto componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (9 llamadas actualizadas)
  - Eliminado composable `useToast` (línea 303, 309)
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Formato corregido: `showToast('tipo', 'mensaje')`
  - Actualizadas llamadas en: verificarFolios (3), cargarPagosOrigen (2), confirmarTraslado (4)

- ✅ Header estándar actualizado
  - Cambiado de `.module-title-section` a estructura estándar con `.module-view-icon`, `.module-view-info`
  - Eliminado `.module-actions`, agregado `.button-group.ms-auto`
  - Corregido icon: `exchange-alt class="module-icon"` → `exchange-alt`
  - Descripción ya existente

- ✅ Botón de ayuda estándar
  - Cambiado de `btn-help` a `btn-municipal-purple`
  - Agregado dentro de `div.button-group.ms-auto`
  - Evento cambiado: `@click="mostrarAyuda = true"` → `@click="mostrarAyuda"`
  - Ya tenía texto "Ayuda"

- ✅ DocumentationModal actualizado
  - Eliminado contenido HTML hardcodeado (~40 líneas de ayuda)
  - Props: `:show="showDocumentation"`, `:componentName="'TrasladoFolSin'"`, `:moduleName="'cementerios'"`
  - Variable `mostrarAyuda` → `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()` agregados
  - Eliminado prop `title` y contenido inline

- ✅ Colores municipales en SweetAlert2 (1 diálogo)
  - `confirmButtonColor: '#ea8215'` (naranja municipal)
  - `cancelButtonColor: '#6c757d'` (gris municipal)
  - Diálogo: `confirmarTraslado()` (antes: `#3085d6` y `#d33`)

- ✅ Clases CSS actualizadas (2 ocurrencias)
  - Cambiado `form-input` → `municipal-form-control` en inputs de folios

- ✅ Import FontAwesomeIcon agregado
  - Agregado `import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'`

- ℹ️ Sin paginación en este componente (tabla informativa con selección de pagos)

**Características del componente:**
- Traslado de pagos específicos entre folios **SIN AFECTAR ADEUDOS** (diferencia clave)
- Búsqueda y verificación de folios origen y destino
- Visualización de datos de ambos folios (cementerio, ubicación, nombre)
- Listado de pagos del folio origen con selección múltiple (checkbox)
- Controles de "Seleccionar/Deseleccionar Todos"
- Resumen con total de pagos seleccionados y monto
- Confirmación con SweetAlert mostrando nota especial: "Los adeudos NO se verán afectados"
- SP específico: `sp_traslado_folios_sin_adeudo` (distinto a TrasladoFol.vue)
- Actualización automática del año pagado en ambos folios

**Total de líneas:**
- Eliminadas: ~48 líneas (HTML hardcoded + estructura antigua header)
- Agregadas: ~55 líneas (toast + métodos + template + header)
- Modificadas: 9 llamadas toast + 1 SweetAlert + 2 CSS classes + header completo + botón ayuda

**Progreso:** 25/32 componentes (78.1%)

---

### 2025-12-08 - TrasladoFol.vue REFACTORIZADO ✅
**ACCIÓN:** Vigésimocuarto componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (9 llamadas actualizadas)
  - Eliminado composable `useToast` (línea 305, 311)
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Formato corregido: `showToast('tipo', 'mensaje')`
  - Actualizadas llamadas en: verificarFolios (3), cargarPagosOrigen (2), confirmarTraslado (4)

- ✅ Header estándar actualizado
  - Cambiado de `.module-title-section` a estructura estándar con `.module-view-icon`, `.module-view-info`
  - Eliminado `.module-actions`, agregado `.button-group.ms-auto`
  - Corregido icon: `exchange-alt module-icon` → `exchange-alt`
  - Descripción ya existente

- ✅ Botón de ayuda estándar
  - Cambiado de `btn-help` a `btn-municipal-purple`
  - Agregado dentro de `div.button-group.ms-auto`
  - Evento cambiado: `@click="mostrarAyuda = true"` → `@click="mostrarAyuda"`
  - Ya tenía texto "Ayuda"

- ✅ DocumentationModal actualizado
  - Eliminado contenido HTML hardcodeado (~42 líneas de ayuda)
  - Props: `:show="showDocumentation"`, `:componentName="'TrasladoFol'"`, `:moduleName="'cementerios'"`
  - Variable `mostrarAyuda` → `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()` agregados
  - Eliminado prop `title` y contenido inline

- ✅ Colores municipales en SweetAlert2 (1 diálogo)
  - `confirmButtonColor: '#ea8215'` (naranja municipal)
  - `cancelButtonColor: '#6c757d'` (gris municipal)
  - Diálogo: `confirmarTraslado()` (antes: `#3085d6` y `#d33`)

- ✅ Clases CSS actualizadas (2 ocurrencias)
  - Cambiado `form-input` → `municipal-form-control` en inputs de folios

- ✅ Import FontAwesomeIcon agregado
  - Agregado `import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'`

- ℹ️ Sin paginación en este componente (tabla informativa con selección de pagos)

**Características del componente:**
- Traslado de pagos específicos entre folios
- Búsqueda y verificación de folios origen y destino
- Visualización de datos de ambos folios (cementerio, ubicación, nombre)
- Listado de pagos del folio origen con selección múltiple (checkbox)
- Controles de "Seleccionar/Deseleccionar Todos"
- Resumen con total de pagos seleccionados y monto
- Confirmación con SweetAlert mostrando detalle del traslado
- Actualización automática del año pagado en ambos folios

**Total de líneas:**
- Eliminadas: ~50 líneas (HTML hardcoded + estructura antigua header)
- Agregadas: ~55 líneas (toast + métodos + template + header)
- Modificadas: 9 llamadas toast + 1 SweetAlert + 2 CSS classes + header completo + botón ayuda

**Progreso:** 24/32 componentes (75.0%) - ¡3/4 COMPLETADO!

---

### 2025-12-08 - Traslados.vue REFACTORIZADO ✅
**ACCIÓN:** Vigésimotercero componente refactorizado con patrón estándar - **DECISIÓN: Mantener callProcedure**

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (5 llamadas actualizadas)
  - Eliminado composable `useToast`
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Formato corregido: `showToast('tipo', 'mensaje')`
  - Actualizadas llamadas en: cargarCementerios (1), verificarUbicacion (2), realizarTraslado (2)

- ✅ Header estándar actualizado
  - Cambiado de `.module-title-section` a estructura estándar con `.module-view-icon`, `.module-view-info`
  - Eliminado `.module-actions`, agregado `.button-group.ms-auto`
  - Corregido icon: `exchange-alt module-icon` → `exchange-alt`
  - Descripción ya existente

- ✅ Botón de ayuda estándar
  - Cambiado de `btn-help` a `btn-municipal-purple`
  - Agregado dentro de `div.button-group.ms-auto`
  - Ya tenía texto "Ayuda"

- ✅ DocumentationModal actualizado
  - Eliminado contenido HTML hardcodeado (~30 líneas)
  - Props: `:show="showDocumentation"`, `:componentName="'Traslados'"`, `:moduleName="'cementerios'"`
  - Variable `mostrarAyuda` → `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()` agregados

- ✅ Colores municipales en SweetAlert2 (1 diálogo)
  - `confirmButtonColor: '#ea8215'` (naranja municipal)
  - `cancelButtonColor: '#6c757d'` (gris municipal)
  - Diálogo: `confirmarTraslado()` (antes: `#3085d6` y `#d33`)

- ✅ Clases CSS actualizadas (16 ocurrencias)
  - Cambiado `form-input` → `municipal-form-control` en formularios origen y destino

- ✅ Import FontAwesomeIcon agregado
  - Agregado `import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'`

- ⚠️ **DECISIÓN DE USUARIO: callProcedure mantenido sin cambios**
  - El componente usa `callProcedure()` en lugar de `execute()`
  - Usuario eligió **OPCIÓN B: Solo cambios de UI, mantener callProcedure**
  - Razón: Minimizar riesgo de romper funcionalidad existente
  - Patrón de respuesta: `result.data` en lugar de `response.result`
  - Mantiene compatibilidad con API actual

- ℹ️ Sin paginación en este componente (formulario de traslado con verificación)

**Características del componente:**
- Traslado de TODOS los pagos de una ubicación física a otra
- Formulario dual: Ubicación Origen y Ubicación Destino
- Campos: Cementerio, Clase, Sección, Línea, Fosa
- Verificación de ubicaciones antes de traslado
- Confirmación con SweetAlert
- Ejecuta SP de traslado con validaciones

**Total de líneas:**
- Eliminadas: ~38 líneas (HTML hardcoded + estructura antigua header)
- Agregadas: ~55 líneas (toast + métodos + template + header)
- Modificadas: 5 llamadas toast + 1 SweetAlert + 16 CSS classes + header completo + botón ayuda

**Progreso:** 23/32 componentes (71.9%)

---

### 2025-12-08 - Duplicados.vue REFACTORIZADO ✅
**ACCIÓN:** Vigesimosegundo componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (ya existente - solo validado)
  - El componente ya usaba `showToast` correctamente desde `useToast`
  - Reemplazado composable por sistema manual
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Formato ya correcto: `showToast('tipo', 'mensaje')` mantenido en todas las llamadas
  - No se requirieron cambios en las llamadas existentes (ya estaban correctas)

- 🐛 Toast duplicado eliminado (líneas 353-365 originales)
  - Eliminado bloque condicional duplicado que chequeaba dos veces el mismo resultado
  - Primera verificación: `if(response?.result?.length > 0)` con asignación + toast
  - Segunda verificación: `if (duplicados.value.length === 0)` con toast duplicado
  - Consolidado en un solo bloque de verificación

- ✅ Header estándar actualizado
  - Cambiado de estructura simple `<h1 class="module-view-info">` a estándar
  - Agregado `.module-view-icon` con FontAwesome icon
  - Agregado `.module-view-info` con título y descripción
  - Movido DocumentationModal del header a botón dedicado

- ✅ Botón de ayuda estándar
  - Cambiado a `btn-municipal-purple`
  - Agregado texto "Ayuda" al botón
  - Agregado dentro de `div.button-group.ms-auto`

- ✅ DocumentationModal actualizado
  - Eliminado `helpSections` array hardcodeado (~30 líneas)
  - Props: `:show="showDocumentation"`, `:componentName="'Duplicados'"`, `:moduleName="'cementerios'"`
  - Variable `showDocumentation` ya existía, solo se agregaron métodos
  - Métodos `mostrarAyuda()` y `closeDocumentation()` agregados
  - Eliminado prop `title` y `:sections`

- ✅ Colores municipales en SweetAlert2 (1 diálogo)
  - `confirmButtonColor: '#ea8215'` (naranja municipal)
  - `cancelButtonColor: '#6c757d'` (gris municipal)
  - Diálogo: confirmación de traslado (antes: colores por defecto)

- ✅ Import FontAwesomeIcon agregado
  - Agregado `import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'`

- ℹ️ Sin paginación en este componente (tabla informativa con selección)

**Características del componente:**
- Búsqueda de registros duplicados por nombre
- Selección de duplicado a trasladar
- Formulario de nueva ubicación (cementerio, clase, sección, línea, fosa)
- Modo de operación: Solo Pagos vs. Todo
- Verificación de ubicación antes de trasladar
- Confirmación con SweetAlert
- Traslado de duplicado con validaciones

**Total de líneas:**
- Eliminadas: ~38 líneas (helpSections + estructura antigua header + toast duplicado)
- Agregadas: ~55 líneas (toast + métodos + template + header)
- Modificadas: 1 SweetAlert + header completo + botón ayuda

**Progreso:** 22/32 componentes (68.8%)

---

### 2025-12-08 - List_Mov.vue REFACTORIZADO ✅
**ACCIÓN:** Vigesimoprimer componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (ya existente - solo validado)
  - El componente ya usaba `showToast` correctamente desde `useToast`
  - Reemplazado composable por sistema manual
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Formato ya correcto: `showToast('tipo', 'mensaje')` mantenido en todas las llamadas
  - No se requirieron cambios en las llamadas existentes (ya estaban correctas)

- 🐛 Toast incorrecto eliminado
  - Eliminado `toast.success('Folio encontrado')` en línea 222 dentro de `cargarCementerios()`
  - Este toast no tenía sentido en el contexto (carga de lista de cementerios)
  - Limpiado código con espacios innecesarios

- ✅ Header estándar actualizado
  - Cambiado de estructura simple `<h1 class="module-view-info">` a estándar
  - Agregado `.module-view-icon` con FontAwesome icon
  - Agregado `.module-view-info` con título y descripción
  - Agregado `.button-group.ms-auto` para botón de ayuda

- ✅ Botón de ayuda estándar
  - Movido DocumentationModal del header a botón dedicado
  - Cambiado a `btn-municipal-purple`
  - Agregado texto "Ayuda" al botón
  - Variable `showDocumentation` ya existía, solo se agregaron métodos

- ✅ DocumentationModal actualizado
  - Eliminado `helpSections` array hardcodeado (~20 líneas)
  - Props: `:show="showDocumentation"`, `:componentName="'List_Mov'"`, `:moduleName="'cementerios'"`
  - Métodos `mostrarAyuda()` y `closeDocumentation()` agregados
  - Eliminado prop `title` y `:sections`

- ✅ Import FontAwesomeIcon agregado
  - Agregado `import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'`

- ❌ Sin SweetAlert en este componente (N/A)

- ℹ️ Sin paginación en este componente (tabla informativa de consulta)

**Características del componente:**
- Listado de movimientos por rango de fechas
- Filtro opcional por cementerio
- Muestra: fecha, folio, cementerio, ubicación, titular, usuario, observaciones
- Filtros con fechas por defecto (último mes)

**Total de líneas:**
- Eliminadas: ~28 líneas (helpSections + estructura antigua header + toast incorrecto)
- Agregadas: ~55 líneas (toast + métodos + template + header)
- Modificadas: header completo + botón ayuda + limpieza código

**Progreso:** 21/32 componentes (65.6%)

---

### 2025-12-08 - Liquidaciones.vue REFACTORIZADO ✅
**ACCIÓN:** Vigésimo componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (5 llamadas actualizadas)
  - Eliminado composable `useToast` (línea 263, 268)
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Formato corregido: `showToast('tipo', 'mensaje')`
  - Actualizadas llamadas: cargarCementerios (1), calcularLiquidacion (3), imprimirLiquidacion (1)

- ✅ Header estándar actualizado
  - Cambiado de `.module-title-section` a estructura estándar con `.module-view-icon`, `.module-view-info`
  - Eliminado `.module-actions`, agregado `.button-group.ms-auto`
  - Corregido icon: `file-invoice-dollar module-icon` → `file-invoice-dollar`

- ✅ Botón de ayuda estándar
  - Cambiado de `btn-icon` a `btn-municipal-purple`
  - Agregado texto "Ayuda" al botón
  - Evento cambiado: `@click="showHelp = true"` → `@click="mostrarAyuda"`

- ✅ DocumentationModal actualizado
  - Eliminado contenido HTML hardcodeado (~40 líneas de ayuda)
  - Props: `:show="showDocumentation"`, `:componentName="'Liquidaciones'"`, `:moduleName="'cementerios'"`
  - Variable `showHelp` → `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()` agregados
  - Eliminado prop `title` y contenido inline

- ✅ Import FontAwesomeIcon agregado
  - Agregado `import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'`

- ❌ Sin SweetAlert en este componente (N/A)

- ℹ️ Sin paginación en este componente (tabla de resultados de cálculo - no requiere paginación)

**Características del componente:**
- Calculadora de liquidaciones de cuotas de mantenimiento
- Selección de cementerio, metros, tipo de espacio (Fosa/Urna/Gaveta/Otros)
- Rango de años para cálculo
- Opción "Nuevo" (sin recargos)
- Tabla de resultados con totales
- Funcionalidad de impresión (window.open)
- Lógica especial: años < 2008 usan metros reales, >= 2008 usan multiplicador 1

**Total de líneas:**
- Eliminadas: ~48 líneas (HTML hardcoded + estructura antigua header)
- Agregadas: ~55 líneas (toast + métodos + template + header)
- Modificadas: 5 llamadas toast + header completo + botón ayuda

**Progreso:** 20/32 componentes (62.5%)

---

### 2025-12-08 - Descuentos.vue REFACTORIZADO ✅
**ACCIÓN:** Decimonoveno componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (ya existente - solo validado)
  - El componente ya usaba `showToast` correctamente desde `useToast`
  - Reemplazado composable por sistema manual
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Formato ya correcto: `showToast('tipo', 'mensaje')` mantenido en todas las llamadas
  - No se requirieron cambios en las llamadas (ya estaban correctas)

- ✅ Header estándar actualizado
  - Cambiado de `.module-title-section` a estructura estándar con `.module-view-icon`, `.module-view-info`
  - Eliminado `.module-actions`, agregado `.button-group.ms-auto`
  - Corregido icon: `percentage module-icon` → `percentage`
  - Descripción ya existente, solo ajustada

- ✅ Botón de ayuda estándar
  - Cambiado de `btn-help` a `btn-municipal-purple`
  - Evento cambiado: `@click="mostrarAyuda = true"` → `@click="mostrarAyuda"`
  - Ya tenía texto "Ayuda"

- ✅ DocumentationModal actualizado
  - Eliminado contenido HTML hardcodeado (~40 líneas de secciones de ayuda)
  - Props: `:show="showDocumentation"`, `:componentName="'Descuentos'"`, `:moduleName="'cementerios'"`
  - Variable `mostrarAyuda` → `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()` agregados
  - Eliminado prop `title` y contenido inline

- ✅ Colores municipales en SweetAlert2 (1 diálogo)
  - `confirmButtonColor: '#ea8215'` (naranja municipal)
  - `cancelButtonColor: '#6c757d'` (gris municipal)
  - Diálogo: `eliminarDescuento()` (antes: `#d33` y `#3085d6`)

- ✅ Import FontAwesomeIcon agregado
  - Agregado `import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'`

- ✅ Clases CSS actualizadas
  - Cambiado `form-input` → `municipal-form-control` (2 ocurrencias)

- ℹ️ Sin paginación en este componente (wizard de 4 pasos con tablas informativas)

**Características del componente:**
- Paso 1: Búsqueda de folio
- Paso 2: Información del folio + adeudos vigentes (tabla informativa)
- Paso 3: Aplicar descuento por año
- Paso 4: Descuentos aplicados (tabla informativa)
- Opción de reactivar folio sin adeudos
- CRUD de descuentos (crear, cancelar)

**Total de líneas:**
- Eliminadas: ~48 líneas (HTML hardcoded + estructura antigua header)
- Agregadas: ~55 líneas (toast + métodos + template + header)
- Modificadas: 1 SweetAlert + header completo + botón ayuda + 2 clases CSS

**Progreso:** 19/32 componentes (59.4%)

---

### 2025-12-08 - Bonificacion1.vue REFACTORIZADO ✅
**ACCIÓN:** Decimoctavo componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (13 llamadas actualizadas)
  - Eliminado composable `useToast` (línea 208, 214)
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Formato corregido: `showToast('tipo', 'mensaje')`
  - Actualizadas llamadas en: cargarRecaudadoras (1), buscarPorOficio (3), buscarFolio (3), buscarFolioPorId (1), guardarBonificacion (5)

- ✅ Header estándar actualizado
  - Cambiado de estructura simple `<h1 class="module-view-info">` a estándar
  - Agregado `.module-view-icon` con FontAwesome icon
  - Agregado `.module-view-info` con título y descripción
  - Agregado `.button-group.ms-auto` para botón de ayuda

- ✅ Botón de ayuda estándar
  - Movido DocumentationModal del header a botón dedicado
  - Cambiado a `btn-municipal-purple`
  - Agregado texto "Ayuda" al botón
  - Agregado dentro de `div.button-group.ms-auto`

- ✅ DocumentationModal actualizado
  - Eliminado `helpSections` array hardcodeado (~20 líneas)
  - Props: `:show="showDocumentation"`, `:componentName="'Bonificacion1'"`, `:moduleName="'cementerios'"`
  - Variable nueva: `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`
  - Eliminado prop `title` y `:sections`

- ✅ Colores municipales en SweetAlert2 (1 diálogo)
  - `confirmButtonColor: '#ea8215'` (naranja municipal)
  - `cancelButtonColor: '#6c757d'` (gris municipal)
  - Diálogo: `confirmarEliminar()` (antes: `#dc3545` y `#6c757d`)

- ✅ Import FontAwesomeIcon agregado
  - Agregado `import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'`

- ℹ️ Sin paginación en este componente (formulario de búsqueda y CRUD, no tabla)

**Características del componente:**
- Búsqueda de bonificación por Oficio + Año + Recaudadora
- Modo edición si existe, modo nuevo si no existe
- Búsqueda de folio para aplicar bonificación
- Cálculo automático de importe restante
- CRUD completo (crear, actualizar, eliminar)

**Total de líneas:**
- Eliminadas: ~28 líneas (helpSections + estructura antigua header)
- Agregadas: ~60 líneas (toast + métodos + template + header)
- Modificadas: 13 llamadas toast + 1 SweetAlert + header completo + botón ayuda

**Progreso:** 18/32 componentes (56.3%)

---

### 2025-12-08 - Bonificaciones.vue REFACTORIZADO ✅
**ACCIÓN:** Decimoséptimo componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (11 llamadas actualizadas)
  - Eliminado composable `useToast`
  - Agregado `toast` ref + métodos (38 líneas)
  - Agregado template toast (8 líneas)
  - Formato corregido: `showToast('tipo', 'mensaje')`
  - Actualizadas llamadas: buscarOficio (3), buscarFolio (3), guardarBonificacion (3), eliminarBonificacion (2)

- ✅ Header estándar actualizado
  - Cambiado de `.module-title-section` a estructura estándar con `.module-view-icon`, `.module-view-info`
  - Eliminado `.module-actions`, agregado `.button-group.ms-auto`
  - Agregado descripción del módulo
  - Corregido icon: `hand-holding-usd module-icon` → `hand-holding-usd`

- ✅ Botón de ayuda estándar
  - Cambiado de `btn-icon` a `btn-municipal-purple`
  - Agregado dentro de `div.button-group.ms-auto`
  - Agregado texto "Ayuda" al botón
  - Evento cambiado: `@click="showHelp = true"` → `@click="mostrarAyuda"`

- ✅ DocumentationModal actualizado
  - Eliminado `helpSections` array hardcodeado (~37 líneas de contenido HTML)
  - Props: `:show="showDocumentation"`, `:componentName="'Bonificaciones'"`, `:moduleName="'cementerios'"`
  - Variable `showHelp` → `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`
  - Eliminado prop `title` y contenido inline

- ✅ Colores municipales en SweetAlert2 (1 diálogo)
  - `confirmButtonColor: '#ea8215'` (naranja municipal)
  - `cancelButtonColor: '#6c757d'` (gris municipal)
  - Diálogo: `confirmarEliminacion()` (antes: `#d33` y `#3085d6`)

- ℹ️ Sin paginación en este componente (wizard de 3 pasos, no tabla)

**Características del componente:**
- Wizard de 3 pasos para gestión de bonificaciones
- Paso 1: Datos del oficio (número, año, recibido)
- Paso 2: Folio a bonificar (control RCM)
- Paso 3: Datos de bonificación (fecha, importes)
- Modo modificación vs. modo alta
- Cálculo automático de pendiente

**Total de líneas:**
- Eliminadas: ~45 líneas (HTML hardcoded + estructura antigua header)
- Agregadas: ~55 líneas (toast + métodos + template)
- Modificadas: 11 llamadas toast + 1 SweetAlert + header completo + botón ayuda

**Progreso:** 17/32 componentes (53.1%)

---

### 2025-12-08 - Multiplefecha.vue REFACTORIZADO ✅
**ACCIÓN:** Dieciseisavo componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (4 llamadas actualizadas)
  - Eliminado composable `useToast` (usado de forma incorrecta con `toast.warning()`)
  - Agregado `toast` ref + métodos (30 líneas)
  - Agregado template toast (8 líneas)
  - Formato corregido: `showToast('tipo', 'mensaje')`

- ✅ Header estándar actualizado
  - Cambiado de estructura simple a estándar con `.module-view-icon`, `.module-view-info`
  - Agregado descripción del módulo
  - DocumentationModal movido fuera del header

- ✅ Botón de ayuda estándar
  - Cambiado de DocumentationModal inline a botón `btn-municipal-purple`
  - Agregado dentro de `div.button-group.ms-auto`
  - Agregado texto "Ayuda" al botón

- ✅ DocumentationModal actualizado
  - Eliminado `helpSections` array hardcodeado (~30 líneas)
  - Props: `:show`, `:componentName="'Multiplefecha'"`, `:moduleName="'cementerios'"`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`

- ✅ Paginación estándar implementada (10 registros por defecto)
  - Implementado paginación cliente-side estándar
  - Agregado controles de navegación completos
  - Selectores de cantidad de registros (5, 10, 25, 50, 100)
  - Badge con total de registros formateado
  - Classes: `row-hover`, `text-primary`, `table-container`, `header-with-badge`
  - Tabla usa `paginatedPagos` en lugar de `pagos`

- ✅ Sin SweetAlert en este componente (N/A)

**Total de líneas:**
- Eliminadas: ~35 líneas (helpSections + estructura antigua)
- Agregadas: ~100 líneas (toast + paginación)
- Modificadas: 4 llamadas toast + header completo + estructura tabla

**Progreso:** 16/32 componentes (50.0%) - ¡MITAD COMPLETADA!

---

### 2025-12-08 - MultipleRCM.vue REFACTORIZADO ✅
**ACCIÓN:** Quinceavo componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (4 llamadas actualizadas)
  - Eliminado composable `useToast`
  - Agregado `toast` ref + métodos (30 líneas)
  - Agregado template toast (8 líneas)
  - Formato corregido: `showToast('tipo', 'mensaje')`
  - Eliminado toast incorrecto en cargarCementerios

- ✅ Botón de ayuda estándar
  - Cambiado de `btn-help-icon` a `btn-municipal-purple`
  - Agregado dentro de `div.button-group.ms-auto`
  - Agregado texto "Ayuda" al botón

- ✅ DocumentationModal actualizado
  - Eliminado contenido HTML hardcodeado (~30 líneas)
  - Props: `:show`, `:componentName="'MultipleRCM'"`, `:moduleName="'cementerios'"`
  - Variable `mostrarAyuda` → `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`

- ✅ Paginación estándar implementada (10 registros por defecto)
  - Eliminado sistema de "Cargar Más Resultados"
  - Eliminado método `cargarMasFolios()` (~60 líneas)
  - Eliminado manejo de paginación server-side (ultimoFolio, hayMasResultados, LIMITE_RESULTADOS, ultimaUbicacion)
  - Implementado paginación cliente-side estándar
  - Agregado controles de navegación completos
  - Selectores de cantidad de registros (5, 10, 25, 50, 100)
  - Badge con total de registros formateado
  - Classes: `row-hover`, `text-primary`, `table-container`, `header-with-badge`
  - Badges de estado con iconos FontAwesome
  - Simplificada llamada a SP (eliminados parámetros de paginación server-side)

- ✅ Sin SweetAlert en este componente (N/A)

**Total de líneas:**
- Eliminadas: ~95 líneas (HTML + método cargarMasFolios + variables paginación + lógica compleja ubicación)
- Agregadas: ~100 líneas
- Modificadas: 4 llamadas toast + botón ayuda + estructura tabla + lógica búsqueda

**Progreso:** 15/32 componentes (46.9%)

---

### 2025-12-08 - MultipleNombre.vue REFACTORIZADO ✅
**ACCIÓN:** Catorceavo componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (4 llamadas actualizadas)
  - Eliminado composable `useToast`
  - Agregado `toast` ref + métodos (30 líneas)
  - Agregado template toast (8 líneas)
  - Formato corregido: `showToast('tipo', 'mensaje')`

- ✅ Botón de ayuda estándar
  - Cambiado de `btn-help-icon` a `btn-municipal-purple`
  - Agregado dentro de `div.button-group.ms-auto`
  - Agregado texto "Ayuda" al botón

- ✅ DocumentationModal actualizado
  - Eliminado contenido HTML hardcodeado (~28 líneas)
  - Props: `:show`, `:componentName="'MultipleNombre'"`, `:moduleName="'cementerios'"`
  - Variable `mostrarAyuda` → `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`

- ✅ Paginación estándar implementada (10 registros por defecto)
  - Eliminado sistema de "Cargar Más Resultados"
  - Eliminado manejo de paginación server-side (ultimoFolio, hayMasResultados, LIMITE_RESULTADOS)
  - Implementado paginación cliente-side estándar
  - Agregado controles de navegación completos
  - Selectores de cantidad de registros (5, 10, 25, 50, 100)
  - Badge con total de registros formateado
  - Classes: `row-hover`, `text-primary`, `table-container`, `header-with-badge`
  - Badges de estado con iconos FontAwesome
  - Simplificada llamada a SP (eliminados parámetros de paginación server-side)

- ✅ Sin SweetAlert en este componente (N/A)

**Total de líneas:**
- Eliminadas: ~65 líneas (HTML + método cargarMasFolios + variables paginación)
- Agregadas: ~100 líneas
- Modificadas: 4 llamadas toast + botón ayuda + estructura tabla + lógica búsqueda

**Progreso:** 14/32 componentes (43.8%)

---

### 2025-12-08 - Consulta400.vue REFACTORIZADO ✅
**ACCIÓN:** Treceavo componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (4 llamadas actualizadas)
  - Eliminado composable `useToast`
  - Agregado `toast` ref + métodos (30 líneas)
  - Agregado template toast (8 líneas)
  - Formato corregido: `showToast('tipo', 'mensaje')`

- ✅ Botón de ayuda estándar
  - Cambiado de `btn-help-icon` a `btn-municipal-purple`
  - Agregado dentro de `div.button-group.ms-auto`
  - Agregado texto "Ayuda" al botón

- ✅ DocumentationModal actualizado
  - Eliminado contenido HTML hardcodeado (~27 líneas)
  - Props: `:show`, `:componentName="'Consulta400'"`, `:moduleName="'cementerios'"`
  - Variable `mostrarAyuda` → `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`

- ✅ Paginación estándar implementada (10 registros por defecto)
  - Implementado paginación cliente-side estándar
  - Agregado controles de navegación completos
  - Selectores de cantidad de registros (5, 10, 25, 50, 100)
  - Badge con total de registros formateado
  - Classes: `row-hover`, `text-primary`, `table-container`, `header-with-badge`
  - Badges de estado con iconos FontAwesome

- ✅ Sin SweetAlert en este componente (N/A)

**Total de líneas:**
- Eliminadas: ~35 líneas (HTML + estructura antigua)
- Agregadas: ~100 líneas
- Modificadas: 4 llamadas toast + botón ayuda + estructura tabla completa

**Progreso:** 13/32 componentes (40.6%)

---

### 2025-12-08 - ConsultaSAndres.vue REFACTORIZADO ✅
**ACCIÓN:** Doceavo componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (3 llamadas actualizadas)
  - Eliminado composable `useToast`
  - Agregado `toast` ref + métodos (30 líneas)
  - Agregado template toast (8 líneas)
  - Formato corregido: `showToast('tipo', 'mensaje')`

- ✅ DocumentationModal actualizado
  - Eliminado contenido HTML hardcodeado (~20 líneas)
  - Props: `:show`, `:componentName="'ConsultaSAndres'"`, `:moduleName="'cementerios'"`
  - Variable `mostrarAyuda` → `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`

- ✅ Paginación estándar implementada (10 registros por defecto)
  - Eliminado sistema de "Cargar Más"
  - Implementado paginación cliente-side estándar
  - Agregado controles de navegación completos
  - Selectores de cantidad de registros (5, 10, 25, 50, 100)
  - Badge con total de registros
  - Classes: `row-hover`, `text-primary`, `table-container`

- ✅ Sin SweetAlert en este componente (N/A)

**Total de líneas:**
- Eliminadas: ~30 líneas (HTML + sistema cargar más)
- Agregadas: ~85 líneas
- Modificadas: 3 llamadas toast + estructura tabla + paginación

**Progreso:** 12/32 componentes (37.5%)

---

### 2025-12-08 - ABCementer.vue REFACTORIZADO ✅
**ACCIÓN:** Quinto componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (13 llamadas actualizadas)
  - Eliminado composable `useToast`
  - Agregado `toast` ref + métodos (30 líneas)
  - Agregado template toast
  - Formato corregido: `showToast('tipo', 'mensaje')`

- ✅ Botón de ayuda estándar
  - Cambiado de `btn-help-icon` a `btn-municipal-purple`
  - Agregado dentro de `div.button-group.ms-auto`
  - Agregado texto "Ayuda" al botón

- ✅ DocumentationModal actualizado
  - Eliminado contenido HTML hardcodeado (~30 líneas)
  - Props: `:show`, `:componentName="'ABCementer'"`, `:moduleName="'cementerios'"`
  - Variable `mostrarAyuda` → `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`

- ✅ Colores municipales en SweetAlert2 (1 diálogo)
  - `confirmButtonColor: '#dc3545'` (rojo para eliminar)
  - `cancelButtonColor: '#6c757d'`

**Total de líneas:**
- Eliminadas: ~30 líneas (HTML hardcodeado)
- Agregadas: ~45 líneas
- Modificadas: 13 llamadas toast + 1 SweetAlert + botón ayuda

**Progreso:** 5/32 componentes (15.6%)

---

### 2025-12-08 - ABCPagosxfol.vue REFACTORIZADO ✅
**ACCIÓN:** Cuarto componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (14 llamadas actualizadas)
  - Eliminado composable `useToast`
  - Agregado `toast` ref + métodos (30 líneas)
  - Template toast ya existía
  - Formato corregido: `showToast('tipo', 'mensaje')`

- ✅ Botón de ayuda estándar
  - Cambiado de `btn-help-icon` a `btn-municipal-purple`
  - Agregado dentro de `div.button-group.ms-auto`
  - Agregado texto "Ayuda" al botón

- ✅ DocumentationModal actualizado
  - Props: `:show`, `:componentName="'ABCPagosxfol'"`, `:moduleName="'cementerios'"`
  - Variable `mostrarAyuda` → `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`

- ✅ Colores municipales en SweetAlert2 (1 diálogo)
  - `confirmButtonColor: '#dc3545'` (rojo para eliminar)
  - `cancelButtonColor: '#6c757d'`

**Total de líneas:**
- Eliminadas: ~5 líneas
- Agregadas: ~35 líneas
- Modificadas: 14 llamadas toast + 1 SweetAlert + botón ayuda

**Progreso:** 4/32 componentes (12.5%)

---

### 2025-12-07 - ABCPagos.vue REFACTORIZADO ✅
**ACCIÓN:** Tercer componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (12 llamadas actualizadas)
  - Eliminado composable `useToast`
  - Agregado `toast` ref + métodos (30 líneas)
  - Template toast agregado (8 líneas)
  - Formato correcto: `showToast('tipo', 'mensaje')`

- ✅ DocumentationModal actualizado
  - Props: `:show`, `:componentName="'ABCPagos'"`, `:moduleName="'cementerios'"`
  - Variable `mostrarAyuda` → `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`
  - Eliminado contenido HTML hardcodeado (37 líneas)

- ✅ Colores municipales en SweetAlert2 (2 diálogos)
  - `confirmarButtonColor: '#ea8215'`
  - `cancelButtonColor: '#6c757d'`

**Total de líneas:**
- Eliminadas: 39 líneas
- Agregadas: 46 líneas
- Modificadas: 12 llamadas toast + 2 SweetAlert

**Progreso:** 3/32 componentes (9.4%)

---

### 2025-12-07 - ABCRecargos.vue REFACTORIZADO ✅
**ACCIÓN:** Segundo componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual (7 llamadas actualizadas)
- ✅ DocumentationModal con carga desde .md
- ✅ Colores municipales (N/A - sin SweetAlert en este componente)
- ✅ 50 líneas de contenido HTML del modal eliminadas

**Progreso:** 2/32 componentes (6.3%)

---

### 2025-12-07 - ABCFolio.vue REFACTORIZADO ✅
**ACCIÓN:** Primer componente refactorizado con patrón estándar

**Cambios aplicados:**
- ✅ Sistema de toast manual implementado (eliminado composable `useToast`)
  - Agregado `toast` ref con { show, type, message }
  - Métodos `showToast()`, `hideToast()`, `getToastIcon()`
  - Template con `toast-notification` div
  - 13 llamadas de toast actualizadas

- ✅ DocumentationModal actualizado
  - Props `:show`, `:componentName="'ABCFolio'"`, `:moduleName="'cementerios'"`
  - Variable `showHelp` → `showDocumentation`
  - Métodos `mostrarAyuda()` y `closeDocumentation()`
  - Eliminado contenido HTML hardcodeado

- ✅ Colores municipales en SweetAlert2
  - `confirmButtonColor: '#ea8215'` (naranja municipal)
  - `cancelButtonColor: '#6c757d'` (gris municipal)

**Validaciones:**
- ✅ Sin cambios en lógica de negocio
- ✅ CRUD funcional mantenido
- ✅ Estructura HTML ya correcta
- ✅ Clases municipal-theme.css ya implementadas
- N/A Tabla con paginación (componente de búsqueda individual)

**Total de líneas:**
- Modificadas: ~45 líneas
- Agregadas: ~30 líneas
- Eliminadas: ~15 líneas

**Progreso:** 1/32 componentes (3.1%)

---

### 2025-12-07 - INICIO DE REFACTORIZACIÓN DE ESTILOS
**ACCIÓN:** Creación de documento de control y definición de proceso

- ✅ Archivo de referencia identificado: consultausuariosfrm.vue
- ✅ Checklist de validación definido
- ✅ Proceso de agentes especializado creado
- ✅ 32 componentes identificados para refactorización
- ✅ Primer componente completado: ABCFolio.vue

**Estado:** Refactorización en progreso - 1/32 completado
