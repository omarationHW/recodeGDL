# PLAN DE AGENTES - Verificación Completa Estacionamiento Exclusivo

## Fecha: 2025-12-05
## Objetivo: Verificar y corregir TODOS los 68 componentes del módulo

---

## CONOCIMIENTO BASE (OBLIGATORIO PARA TODOS LOS AGENTES)

### Conexión a Base de Datos PostgreSQL
```
Host: 192.168.6.146
Usuario: refact
Password: FF)-BQk2
Puerto: 5432
```

### Bases de Datos y Esquemas
| Base de Datos | Esquema | Uso |
|---------------|---------|-----|
| estacionamiento_exclusivo | public | Tablas principales del módulo |
| padron_licencias | comun | Tablas compartidas (ejecutores, recaudadoras) |

### Ejecución de SQL vía Batch
```batch
@echo off
set PGPASSWORD=FF)-BQk2
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -h 192.168.6.146 -U refact -d [BASE_DB] -c "[SQL]"
```

### Estructura de Respuesta API
```javascript
// La API devuelve: {result: Array, count: number, debug: {...}}
// Para parsear:
if (Array.isArray(result?.result) && result.result.length > 0) {
  mensaje = result.result[0].result || result.result[0].[nombre_sp] || ''
}
```

### Archivos Pascal Originales
```
C:\Sistemas\RefactorX\Guadalajara\Originales\Code\199\aplicaciones\Ingresos\ApremiosSVN\[NombreComponente].pas
```

### Patrón Vue Estándar
```javascript
// Constantes obligatorias
const BASE_DB = '[base_correcta]'  // estacionamiento_exclusivo o padron_licencias
const SCHEMA = '[esquema]'         // public o comun

// Imports obligatorios
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Composables
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()
```

### Computed Properties para Validaciones Robustas
```javascript
// Para campos que pueden tener valores nulos, vacíos o con espacios
const campoActivo = computed(() => {
  const val = (objeto.campo || '').toString().trim().toUpperCase()
  return val !== 'B'  // o la comparación necesaria
})
```

### SweetAlert Confirmaciones
```javascript
// Antes de operaciones críticas (guardar, eliminar, etc.)
const confirmResult = await Swal.fire({
  icon: 'question',  // o 'warning' para eliminaciones
  title: '¿Confirmar acción?',
  html: `<div>Detalles...</div>`,
  showCancelButton: true,
  confirmButtonColor: '#198754',
  cancelButtonColor: '#6c757d',
  confirmButtonText: 'Sí, Confirmar',
  cancelButtonText: 'Cancelar'
})
if (!confirmResult.isConfirmed) return
```

---

## PROCESO DE VERIFICACIÓN POR COMPONENTE

### Paso 1: Leer archivo Pascal original
- Ubicación: `C:\Sistemas\RefactorX\Guadalajara\Originales\Code\199\aplicaciones\Ingresos\ApremiosSVN\[Componente].pas`
- Identificar: queries SQL, operaciones CRUD, validaciones, lógica de negocio

### Paso 2: Leer componente Vue actual
- Ubicación: `RefactorX/FrontEnd/src/views/modules/estacionamiento_exclusivo/[Componente].vue`
- Verificar: BASE_DB, SCHEMA, operaciones, imports, try/catch

### Paso 3: Verificar SPs en Base de Datos
```batch
set PGPASSWORD=FF)-BQk2
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -h 192.168.6.146 -U refact -d [BASE] -c "SELECT routine_name FROM information_schema.routines WHERE routine_name LIKE '%nombre_sp%' AND routine_schema = '[schema]';"
```

### Paso 4: Crear SPs faltantes
- Crear archivo SQL en: `RefactorX/Base/estacionamiento_exclusivo/database/deploy/`
- Ejecutar con batch file

### Paso 5: Corregir componente Vue
- Ajustar BASE_DB y SCHEMA
- Corregir parseo de respuestas
- Agregar confirmaciones SweetAlert
- Implementar computed properties robustas

### Paso 6: Verificar funcionalmente
- Probar CRUD completo
- Verificar paginación
- Confirmar que no hay errores en consola

---

## DISTRIBUCIÓN DE AGENTES (PARALELO)

### LOTE 1: Catálogos y ABC (8 componentes)
| Componente | Pascal | Prioridad |
|------------|--------|-----------|
| ABCEjec.vue | ABCEjec.pas | ✅ COMPLETADO |
| Ejecutores.vue | Ejecutores.pas | ALTA |
| Reasignacion.vue | Reasignacion.pas | ALTA |
| AutorizaDes.vue | AutorizaDes.pas | ALTA |
| Modifcar.vue | Modifcar.pas | MEDIA |
| Modificar_bien.vue | Modificar_bien.pas | MEDIA |
| Modif_Masiva.vue | Modif_Masiva.pas | MEDIA |
| sfrm_chgpass.vue | sfrm_chgpass.pas | BAJA |

### LOTE 2: Consultas (7 componentes)
| Componente | Pascal | Prioridad |
|------------|--------|-----------|
| Individual.vue | Individual.pas | ALTA |
| Individual_Folio.vue | Individual_Folio.pas | ALTA |
| ConsultaReg.vue | ConsultaReg.pas | ALTA |
| Cons_his.vue | Cons_his.pas | MEDIA |
| EstadxFolio.vue | EstadxFolio.pas | MEDIA |
| CMultEmision.vue | CMultEmision.pas | MEDIA |
| CMultFolio.vue | CMultFolio.pas | MEDIA |

### LOTE 3: Listados y Filtros (10 componentes)
| Componente | Pascal | Prioridad |
|------------|--------|-----------|
| Listados.vue | Listados.pas | ALTA |
| Listados_Ade.vue | Listados_Ade.pas | ALTA |
| ListadosSinAdereq.vue | ListadosSinAdereq.pas | MEDIA |
| ListxReg.vue | ListxReg.pas | MEDIA |
| ListxFec.vue | ListxFec.pas | MEDIA |
| List_Eje.vue | List_Eje.pas | MEDIA |
| Lista_Eje.vue | Lista_Eje.pas | MEDIA |
| Lista_GastosCob.vue | Lista_GastosCob.pas | MEDIA |
| ListadosAdeAseoForm.vue | - | BAJA |
| ListadosAdeExclusivosForm.vue | - | BAJA |

### LOTE 4: Operaciones (8 componentes)
| Componente | Pascal | Prioridad |
|------------|--------|-----------|
| Facturacion.vue | Facturacion.pas | ALTA |
| Requerimientos.vue | Requerimientos.pas | ALTA |
| Recuperacion.vue | Recuperacion.pas | ALTA |
| Notificaciones.vue | Notificaciones.pas | ALTA |
| NotificacionesMes.vue | NotificacionesMes.pas | MEDIA |
| Prenomina.vue | Prenomina.pas | MEDIA |
| CartaInvitacion.vue | CartaInvitacion.pas | MEDIA |
| FirmaElectronica.vue | FirmaElectronica.pas | MEDIA |

### LOTE 5: Apremios SVN (6 componentes)
| Componente | Pascal | Prioridad |
|------------|--------|-----------|
| ApremiosSvnExpedientes.vue | - | ALTA |
| ApremiosSvnFases.vue | - | ALTA |
| ApremiosSvnActuaciones.vue | - | ALTA |
| ApremiosSvnNotificaciones.vue | - | ALTA |
| ApremiosSvnPagos.vue | - | ALTA |
| ApremiosSvnReportes.vue | - | ALTA |

### LOTE 6: Reportes Rprt (8 componentes)
| Componente | Pascal | Prioridad |
|------------|--------|-----------|
| RprtCATAL_EJE.vue | RprtCATAL_EJE.pas | MEDIA |
| RprtEstadxfolio.vue | RprtEstadxfolio.pas | MEDIA |
| RprtList_Eje.vue | RprtList_Eje.pas | MEDIA |
| RprtListados.vue | RprtListados.pas | MEDIA |
| RprtListaxFec.vue | RprtListaxFec.pas | MEDIA |
| RprtListaxRegAseo.vue | RprtListaxRegAseo.pas | BAJA |
| RprtListaxRegEstacionometro.vue | RprtListaxRegEstacionometro.pas | BAJA |
| RprtListaxRegMer.vue | RprtListaxRegMer.pas | BAJA |

### LOTE 7: Reportes Rpt (11 componentes)
| Componente | Pascal | Prioridad |
|------------|--------|-----------|
| RptFact_Merc.vue | RptFact_Merc.pas | MEDIA |
| RptLista_mercados.vue | RptLista_mercados.pas | MEDIA |
| RptListado_Aseo.vue | RptListado_Aseo.pas | MEDIA |
| RptListaxRegPub.vue | RptListaxRegPub.pas | MEDIA |
| RptPrenomina.vue | RptPrenomina.pas | MEDIA |
| RptRecup_Aseo.vue | RptRecup_Aseo.pas | BAJA |
| RptRecup_Merc.vue | RptRecup_Merc.pas | BAJA |
| RptReq_Aseo.vue | RptReq_Aseo.pas | BAJA |
| RptReq_Merc.vue | RptReq_Merc.pas | BAJA |
| RptReq_Pba_Aseo.vue | RptReq_Pba_Aseo.pas | BAJA |
| RptReq_pba.vue | RptReq_pba.pas | BAJA |

### LOTE 8: Utilidades y Menús (6 componentes)
| Componente | Pascal | Prioridad |
|------------|--------|-----------|
| index.vue | - | BAJA |
| Menu.vue | Menu.pas | BAJA |
| acceso.vue | acceso.pas | MEDIA |
| ExportarExcel.vue | ExportarExcel.pas | MEDIA |
| ModuloDb.vue | ModuloDb.pas | BAJA |
| UNIT9.vue | UNIT9.PAS | BAJA |
| Loader.vue | - | BAJA |
| ReportAutor.vue | ReportAutor.pas | BAJA |

---

## CHECKLIST POR COMPONENTE

Para cada componente verificar:

- [ ] BASE_DB correcto según tabla utilizada
- [ ] SCHEMA correcto (public/comun)
- [ ] SPs existen en la base de datos
- [ ] Parseo de respuesta API correcto (result.result[])
- [ ] Confirmaciones SweetAlert antes de CRUD
- [ ] Computed properties para valores nullable
- [ ] Try/catch en métodos async
- [ ] Loading global en operaciones
- [ ] Paginación funcional
- [ ] Sin errores en consola
- [ ] Estilos municipal-theme.css aplicados

---

## ERRORES COMUNES A CORREGIR

### 1. BASE_DB incorrecto
```javascript
// INCORRECTO
const BASE_DB = 'multas_reglamentos'
// CORRECTO (según tabla)
const BASE_DB = 'estacionamiento_exclusivo'  // o 'padron_licencias'
```

### 2. Parseo de respuesta
```javascript
// INCORRECTO
const arr = result.rows || []
// CORRECTO
const arr = result?.result || result?.rows || result?.data || []
```

### 3. Comparación de vigencia
```javascript
// INCORRECTO
v-if="ejecutor.vigencia !== 'B'"
// CORRECTO (usar computed)
const activo = computed(() => (obj.vigencia || '').trim() !== 'B')
```

### 4. Sin confirmación antes de acciones
```javascript
// INCORRECTO - ejecuta directo
await guardar()
// CORRECTO - confirma primero
const confirm = await Swal.fire({...})
if (confirm.isConfirmed) await guardar()
```

---

## COMANDOS ÚTILES

### Verificar SP existe
```batch
set PGPASSWORD=FF)-BQk2
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -h 192.168.6.146 -U refact -d estacionamiento_exclusivo -c "SELECT routine_name FROM information_schema.routines WHERE routine_name = 'sp_nombre';"
```

### Ejecutar archivo SQL
```batch
set PGPASSWORD=FF)-BQk2
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -h 192.168.6.146 -U refact -d estacionamiento_exclusivo -f "ruta/archivo.sql"
```

### Ver estructura de tabla
```batch
set PGPASSWORD=FF)-BQk2
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -h 192.168.6.146 -U refact -d estacionamiento_exclusivo -c "\d nombre_tabla"
```

---

## NOTAS IMPORTANTES

1. **NO confiar en el documento CONTROL_IMPLEMENTACION** - dice 100% pero ABCEjec tenía múltiples errores
2. **Siempre verificar SPs en BD** - pueden no existir aunque el código los llame
3. **Probar TODAS las operaciones** - listar, crear, editar, eliminar
4. **Revisar consola del navegador** - detectar errores de parseo
5. **Los archivos Pascal son la fuente de verdad** - la lógica debe coincidir

---

## RESULTADO ESPERADO

Al finalizar:
- 68/68 componentes verificados y funcionales
- Todos los SPs necesarios creados en BD
- Confirmaciones SweetAlert en operaciones CRUD
- Sin errores en consola
- Documento CONTROL_IMPLEMENTACION actualizado con estado real
