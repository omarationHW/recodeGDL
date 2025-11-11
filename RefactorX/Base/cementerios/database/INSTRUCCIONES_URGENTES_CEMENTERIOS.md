# 🚨 INSTRUCCIONES URGENTES - MÓDULO CEMENTERIOS

**PROBLEMA IDENTIFICADO**: Los componentes de Cementerios NO TRAEN DATOS porque:
1. ❌ Usan formato de API INCORRECTO (anticuado)
2. ❌ Estructura HTML/CSS NO sigue estándar de Padrón de Licencias
3. ⚠️ SPs posiblemente NO instalados en PostgreSQL

---

## 🎯 SOLUCIÓN INMEDIATA (3 PASOS)

### PASO 1: Verificar/Instalar SPs en PostgreSQL (30 min)

#### 1.1 Conectar a PostgreSQL

```bash
# Buscar instalación de PostgreSQL
psql --version

# Conectarse a la base de datos
psql -U postgres -d nombre_base_datos
```

#### 1.2 Ejecutar Script de Verificación

```bash
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\cementerios\database

# En Windows (PowerShell):
psql -U postgres -d nombre_bd -f VERIFICAR_SPS_POSTGRESQL.sql

# Alternativamente, desde psql:
\i VERIFICAR_SPS_POSTGRESQL.sql
```

**Resultado esperado**: Debe mostrar aprox. 93 SPs instalados

#### 1.3 Si Faltan SPs: Instalar en Orden

```bash
cd ok/

# Ejecutar archivos en orden numérico:
psql -U postgres -d nombre_bd -f 01_SP_CEMENTERIOS_CORE_all_procedures.sql
psql -U postgres -d nombre_bd -f 02_SP_CEMENTERIOS_GESTION_all_procedures.sql
psql -U postgres -d nombre_bd -f 03_SP_CEMENTERIOS_ABC_all_procedures.sql

# ... continuar con todos los archivos numerados
```

**⚠️ IMPORTANTE**: Los SPs deben instalarse en el esquema `public`

#### 1.4 Verificar Instalación Exitosa

```sql
-- Contar SPs instalados
SELECT COUNT(*) as total
FROM information_schema.routines
WHERE routine_schema = 'public'
    AND (routine_name LIKE 'sp_cem_%' OR routine_name LIKE 'sp_cementerios_%');

-- Debe retornar: total | 93 (aproximadamente)
```

---

### PASO 2: Reemplazar Componente de Prueba (5 min)

#### 2.1 Hacer Backup del Componente Original

```bash
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd\src\views\modules\cementerios

# Renombrar original
mv ConIndividual.vue ConIndividual_ORIGINAL_BACKUP.vue
```

#### 2.2 Aplicar Componente Corregido

```bash
# Renombrar el corregido
mv ConIndividual_CORREGIDO.vue ConIndividual.vue
```

#### 2.3 Verificar Sintaxis (Si tienes npm disponible)

```bash
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd

npm run lint
# O simplemente iniciar el servidor dev para verificar
npm run dev
```

---

### PASO 3: Probar el Componente (10 min)

#### 3.1 Iniciar el Frontend (Si no está corriendo)

```bash
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd
npm run dev
```

#### 3.2 Probar en el Navegador

1. Abrir: `http://localhost:5173` (o el puerto que use)
2. Navegar a: **Cementerios → Consulta Individual**
3. Ingresar un número de folio de prueba (ej: 1, 100, 1000)
4. Hacer clic en **Buscar**

#### 3.3 Resultados Esperados

✅ **SI FUNCIONA**:
- Loading spinner aparece brevemente
- Se muestra la información del folio
- Se muestra el historial de pagos
- Todo con estilos correctos (azul municipal)

❌ **SI FALLA**:
- Abrir Consola del Navegador (F12)
- Ver errores en la pestaña Console
- Ver llamadas fallidas en la pestaña Network
- **Copiar el error y reportar**

---

## 📋 CAMBIOS APLICADOS EN EL COMPONENTE CORREGIDO

### ✅ 1. API Calls (CRÍTICO)

#### ANTES (❌ INCORRECTO):
```javascript
const api = useApi()

const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_FOLIO', {
  p_control_rcm: folioABuscar.value
})

// Datos en response.data
if (response.data && response.data.length > 0) {
  folio.value = response.data[0]
}
```

#### DESPUÉS (✅ CORRECTO):
```javascript
const { execute } = useApi()

const params = [
  {
    nombre: 'p_control_rcm',
    valor: folioABuscar.value,
    tipo: 'integer'
  }
]

const response = await execute(
  'sp_cem_consultar_folio',  // SP en lowercase
  'cementerios',              // Módulo
  params,                     // Array estructurado
  'cementerios',              // Conexión
  null,
  'public'                    // Schema
)

// Datos en response.result (¡NO response.data!)
if (response && response.result && response.result.length > 0) {
  folio.value = response.result[0]
}
```

### ✅ 2. Estructura HTML

#### ANTES (❌):
```vue
<div class="module-container">
  <div class="module-header">
    <h1 class="module-title">
      <i class="fas fa-file-alt"></i>
      Título
    </h1>
  </div>

  <div class="card">
    <div class="card-header">...</div>
    <div class="card-body">
      <input type="text" class="form-control">
    </div>
  </div>
</div>
```

#### DESPUÉS (✅):
```vue
<div class="module-view">
  <div class="module-view-header">
    <div class="module-view-icon">
      <font-awesome-icon icon="file-alt" />
    </div>
    <div class="module-view-info">
      <h1>Título</h1>
      <p>Descripción</p>
    </div>
    <div class="button-group ms-auto">
      <button class="btn-municipal-purple" @click="openDocumentation">
        <font-awesome-icon icon="question-circle" />
        Ayuda
      </button>
    </div>
  </div>

  <div class="module-view-content">
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search" />
          Título
        </h5>
      </div>
      <div class="municipal-card-body">
        <input type="text" class="municipal-form-control">
      </div>
    </div>
  </div>
</div>

<DocumentationModal
  :show="showDocumentation"
  :componentName="'ConIndividual'"
  :moduleName="'cementerios'"
  @close="closeDocumentation"
/>
```

### ✅ 3. Composables Adicionales

```javascript
// AGREGADO:
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showLoading, hideLoading } = useGlobalLoading()

// Usar en llamadas async:
showLoading('Buscando folio...', 'Consultando base de datos')
try {
  const response = await execute(...)
  hideLoading()
  // procesar...
} catch (error) {
  hideLoading()
  // manejar error...
}
```

---

## 🔄 PRÓXIMOS PASOS (Después de Probar)

Una vez que **ConIndividual.vue** funcione correctamente:

### 1. Corregir Componentes CRÍTICOS (En este orden)

1. **ABCFolio.vue** - Alta/Baja/Cambio de folios
2. **ConsultaGuad.vue** - Consulta Guadalajara
3. **ConsultaJar.vue** - Consulta Jardín
4. **ConsultaSAnd.vue** - Consulta San Andrés
5. **ABCPagosxfol.vue** - Gestión de pagos

### 2. Corregir Componentes IMPORTANTES

6-12. Resto de componentes ABC (Recargos, Bonificaciones, Descuentos)
13-16. Reportes (Rep_a_Cobrar, Rep_Bon, RptTitulos, Estad_adeudo)

### 3. Corregir Componentes SECUNDARIOS

17-37. Resto de componentes (Traslados, Liquidaciones, etc.)

---

## 📝 PATRÓN DE CORRECCIÓN PARA OTROS COMPONENTES

Para cada componente adicional, aplicar:

### 1. Script Setup

```javascript
// Cambiar importaciones:
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

// Cambiar inicialización:
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Agregar para modal de ayuda:
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
```

### 2. Función de Llamada API

```javascript
// Template de función genérica:
const funcionConsulta = async () => {
  showLoading('Mensaje...', 'Submensaje...')

  try {
    const params = [
      {
        nombre: 'p_parametro1',
        valor: variable1.value,
        tipo: 'integer' // o 'string', 'date', 'boolean'
      },
      {
        nombre: 'p_parametro2',
        valor: variable2.value || null,
        tipo: 'string'
      }
    ]

    const response = await execute(
      'sp_nombre_lowercase',  // Nombre del SP
      'cementerios',          // Módulo
      params,                 // Parámetros
      'cementerios',          // Conexión
      null,                   // Adicional
      'public'                // Schema
    )

    hideLoading()

    if (response && response.result) {
      datos.value = response.result
      toast.success('Operación exitosa')
    } else {
      datos.value = []
      toast.info('No se encontraron datos')
    }
  } catch (error) {
    hideLoading()
    console.error('Error:', error)
    toast.error('Error: ' + (error.message || 'Error desconocido'))
  }
}
```

### 3. Template HTML

```vue
<template>
  <div class="module-view">
    <div class="module-view-header">
      <!-- Estructura estándar de header -->
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="icono" />
            Título
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Contenido -->
        </div>
      </div>
    </div>
  </div>

  <DocumentationModal
    :show="showDocumentation"
    :componentName="'NombreComponente'"
    :moduleName="'cementerios'"
    @close="closeDocumentation"
  />
</template>
```

---

## 🆘 TROUBLESHOOTING

### Error: "SP no existe"

```
ERROR: function sp_cem_consultar_folio(...) does not exist
```

**Solución**: Los SPs no están instalados. Ejecutar PASO 1.

### Error: "Cannot read property 'result' of undefined"

```
TypeError: Cannot read property 'result' of undefined
```

**Solución**:
1. Verificar que el nombre del SP esté en **lowercase**
2. Verificar que el schema sea correcto ('public')
3. Verificar que los parámetros tengan el tipo correcto

### Error: "execute is not a function"

```
TypeError: execute is not a function
```

**Solución**: Cambiar de `const api = useApi()` a `const { execute } = useApi()`

### No se muestran datos pero no hay error

**Solución**: Verificar que se esté usando `response.result` y NO `response.data`

---

## 📞 CONTACTO Y SOPORTE

**Archivos de Referencia**:
- Diagnóstico completo: `DIAGNOSTICO_CEMENTERIOS_COMPLETO.md`
- Componente corregido: `ConIndividual_CORREGIDO.vue`
- Script verificación: `VERIFICAR_SPS_POSTGRESQL.sql`

**Próximos pasos después de validar**:
1. Si funciona → Aplicar patrón al resto de componentes
2. Si NO funciona → Reportar error específico con logs de consola

---

**Generado**: 2025-11-09
**Autor**: Claude Code
**Prioridad**: 🔴 URGENTE - SISTEMA NO FUNCIONAL
