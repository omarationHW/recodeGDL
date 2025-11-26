<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="hand-holding-usd" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Condonaciones de Energía</h1>
        <p>Inicio > Mercados > Condonaciones Energía</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel"
          :disabled="loading || condonaciones.length === 0">
          <font-awesome-icon icon="file-excel" />
          Excel
        </button>
        <button class="btn-municipal-primary" @click="imprimir"
          :disabled="loading || condonaciones.length === 0">
          <font-awesome-icon icon="print" />
          Imprimir
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <!-- Primera fila: Recaudadora y Mercado -->
          <div class="form-row">
            <div class="form-group" style="flex: 1.5;">
              <label class="municipal-form-label">
                Oficina Recaudadora <span class="required">*</span>
                <small class="text-muted">(Obligatorio)</small>
              </label>
              <select class="municipal-form-control" v-model="form.oficina" @change="cargarMercados" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">
                Mercado
                <small class="text-muted">(Opcional - Deje vacío para todos)</small>
              </label>
              <select class="municipal-form-control" v-model="form.num_mercado" :disabled="loading || !form.oficina">
                <option value="">Todos los mercados</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">
                Sección
                <small class="text-muted">(Opcional)</small>
              </label>
              <select class="municipal-form-control" v-model="form.seccion" :disabled="loading">
                <option value="">Todas las secciones</option>
                <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                  {{ sec.seccion }} - {{ sec.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <!-- Segunda fila: Detalles del local (todos opcionales) -->
          <div class="form-row">
            <div class="form-group" style="flex: 0.8;">
              <label class="municipal-form-label">
                Local
                <small class="text-muted">(Opcional)</small>
              </label>
              <input type="number" class="municipal-form-control" v-model.number="form.local"
                     placeholder="Todos" :disabled="loading" />
            </div>

            <div class="form-group" style="flex: 0.5;">
              <label class="municipal-form-label">Letra</label>
              <input type="text" class="municipal-form-control" v-model="form.letra_local"
                     maxlength="1" placeholder="Cualquiera" :disabled="loading" />
            </div>

            <div class="form-group" style="flex: 0.5;">
              <label class="municipal-form-label">Bloque</label>
              <input type="text" class="municipal-form-control" v-model="form.bloque"
                     maxlength="1" placeholder="Cualquiera" :disabled="loading" />
            </div>

            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">&nbsp;</label>
              <div class="alert alert-info" style="margin-bottom: 0; padding: 0.5rem;">
                <font-awesome-icon icon="info-circle" class="me-2" />
                <small>Los campos opcionales permiten búsquedas más amplias</small>
              </div>
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="buscarCondonaciones" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  Buscar
                </button>
                <button class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
                  <font-awesome-icon icon="eraser" />
                  Limpiar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Información del Local -->
      <div v-if="localInfo" class="municipal-card">
        <div class="municipal-card-header" style="background-color: #17a2b8; color: white;">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Información del Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-3"><strong>ID Local:</strong> {{ localInfo.id_local }}</div>
            <div class="col-md-3"><strong>Nombre:</strong> {{ localInfo.nombre }}</div>
            <div class="col-md-3"><strong>Arrendatario:</strong> {{ localInfo.arrendatario }}</div>
            <div class="col-md-3"><strong>Vigencia:</strong> {{ localInfo.vigencia }}</div>
          </div>
        </div>
      </div>

      <!-- Tabla de Condonaciones -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Condonaciones de Energía
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="condonaciones.length > 0">
              {{ formatNumber(condonaciones.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Buscando condonaciones...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Mercado</th>
                  <th>Sec.</th>
                  <th>Local</th>
                  <th>Nombre</th>
                  <th>Año</th>
                  <th>Per.</th>
                  <th>Fecha</th>
                  <th class="text-end">Imp. Original</th>
                  <th class="text-end">Condonado</th>
                  <th class="text-end">%</th>
                  <th>Motivo</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="condonaciones.length === 0 && !searched">
                  <td colspan="13" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para consultar condonaciones de energía</p>
                  </td>
                </tr>
                <tr v-else-if="condonaciones.length === 0">
                  <td colspan="13" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron condonaciones con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="c in condonaciones" :key="c.id_condonacion" class="row-hover">
                  <td><strong class="text-primary">{{ c.id_condonacion }}</strong></td>
                  <td>{{ c.num_mercado }}</td>
                  <td>{{ c.seccion }}</td>
                  <td>
                    {{ c.local }}
                    <span v-if="c.letra_local" class="text-muted">{{ c.letra_local }}</span>
                    <span v-if="c.bloque" class="text-muted">{{ c.bloque }}</span>
                  </td>
                  <td>
                    <small>{{ c.nombre_local }}</small>
                  </td>
                  <td>{{ c.axo }}</td>
                  <td>{{ c.periodo }}</td>
                  <td>
                    <small>{{ formatDate(c.fecha_condonacion) }}</small>
                  </td>
                  <td class="text-end">
                    <strong class="text-danger">${{ formatNumber(c.importe_original) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-success">${{ formatNumber(c.importe_condonado) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-info">{{ calcPorcentaje(c.importe_original, c.importe_condonado) }}%</strong>
                  </td>
                  <td><small>{{ c.motivo }}</small></td>
                  <td><small>{{ c.usuario }}</small></td>
                </tr>
              </tbody>
              <tfoot v-if="condonaciones.length > 0" class="municipal-table-footer">
                <tr>
                  <td colspan="8"><strong>TOTALES ({{ condonaciones.length }} registros)</strong></td>
                  <td class="text-end"><strong class="text-danger">${{ formatNumber(totales.original) }}</strong></td>
                  <td class="text-end"><strong class="text-success">${{ formatNumber(totales.condonado) }}</strong></td>
                  <td colspan="3"></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'

// Estado
const showFilters = ref(true)
const loading = ref(false)
const searched = ref(false)
const error = ref('')

// Catálogos
const recaudadoras = ref([])
const mercados = ref([])
const secciones = ref([])

// Formulario
const form = ref({
  oficina: '',
  num_mercado: '',
  seccion: '',
  local: '',
  letra_local: '',
  bloque: ''
})

// Datos
const localInfo = ref(null)
const condonaciones = ref([])

// Toast
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('info', 'Ayuda: Seleccione al menos una Oficina Recaudadora. Los demás campos son opcionales para búsquedas más amplias.')
}

const showToast = (type, message) => {
  toast.value = {
    show: true,
    type,
    message
  }
  setTimeout(() => {
    hideToast()
  }, 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'times-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

const formatNumber = (num) => {
  return parseFloat(num || 0).toFixed(2)
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

const calcPorcentaje = (original, condonado) => {
  if (!original || original === 0) return '0.00'
  return ((parseFloat(condonado) / parseFloat(original)) * 100).toFixed(2)
}

const totales = computed(() => {
  return {
    original: condonaciones.value.reduce((sum, c) => sum + parseFloat(c.importe_original || 0), 0),
    condonado: condonaciones.value.reduce((sum, c) => sum + parseFloat(c.importe_condonado || 0), 0)
  }
})

// Cargar catálogos
onMounted(async () => {
  await Promise.all([
    cargarRecaudadoras(),
    cargarSecciones()
  ])
})

const cargarRecaudadoras = async () => {
  loading.value = true
  error.value = ''
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    })
    if (response.data.eResponse?.success) {
      recaudadoras.value = response.data.eResponse.data.result || []
      if (recaudadoras.value.length > 0) {
        showToast('success', `Se cargaron ${recaudadoras.value.length} oficinas recaudadoras`)
      }
    } else {
      error.value = response.data.eResponse?.message || 'Error al cargar recaudadoras'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = 'Error de conexión al cargar recaudadoras'
    console.error('Error al cargar recaudadoras:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
  }
}

const cargarMercados = async () => {
  mercados.value = []
  form.value.num_mercado = ''

  if (!form.value.oficina) return

  loading.value = true
  error.value = ''
  try {
    const nivelUsuario = 1
    const oficinaParam = form.value.oficina || null

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_catalogo_mercados',
        Base: 'padron_licencias',
        Parametros: [
          { nombre: 'p_oficina', tipo: 'integer', valor: oficinaParam },
          { nombre: 'p_nivel_usuario', tipo: 'integer', valor: nivelUsuario }
        ]
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      mercados.value = response.data.eResponse.data.result || []
      if (mercados.value.length > 0) {
        showToast('success', `Se cargaron ${mercados.value.length} mercados`)
      } else {
        showToast('info', 'No se encontraron mercados para esta oficina')
      }
    } else {
      error.value = response.data.eResponse?.message || 'Error al cargar mercados'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = 'Error de conexión al cargar mercados'
    console.error('Error al cargar mercados:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
  }
}

const cargarSecciones = async () => {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_secciones',
        Base: 'padron_licencias',
        Parametros: []
      }
    })
    if (response.data.eResponse?.success) {
      secciones.value = response.data.eResponse.data.result || []
    }
  } catch (error) {
    showToast('error', 'Error al cargar secciones')
  }
}

const buscarCondonaciones = async () => {
  // Solo la oficina es obligatoria
  if (!form.value.oficina) {
    showToast('warning', 'Debe seleccionar una Oficina Recaudadora')
    return
  }

  loading.value = true
  searched.value = false
  error.value = ''
  localInfo.value = null
  condonaciones.value = []

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cons_condonacion_energia',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) },
          { Nombre: 'p_num_mercado', Valor: form.value.num_mercado ? parseInt(form.value.num_mercado) : null },
          { Nombre: 'p_categoria', Valor: 1 },
          { Nombre: 'p_seccion', Valor: form.value.seccion || null },
          { Nombre: 'p_local', Valor: form.value.local ? parseInt(form.value.local) : null },
          { Nombre: 'p_letra_local', Valor: form.value.letra_local || null },
          { Nombre: 'p_bloque', Valor: form.value.bloque || null }
        ]
      }
    })

    searched.value = true

    if (response.data.eResponse?.success && response.data.eResponse?.data) {
      condonaciones.value = response.data.eResponse.data.result || []

      if (condonaciones.value.length > 0) {
        // Si hay un solo local, mostrar su info
        if (form.value.local) {
          const firstRecord = condonaciones.value[0]
          localInfo.value = {
            id_local: firstRecord.id_local,
            nombre: firstRecord.nombre_local,
            arrendatario: firstRecord.arrendatario,
            vigencia: firstRecord.vigencia
          }
        }

        const criterios = []
        if (form.value.num_mercado) criterios.push('Mercado')
        if (form.value.seccion) criterios.push('Sección')
        if (form.value.local) criterios.push('Local')

        const msg = criterios.length > 0
          ? `Se encontraron ${condonaciones.value.length} condonaciones (${criterios.join(', ')})`
          : `Se encontraron ${condonaciones.value.length} condonaciones en toda la oficina`

        showToast('success', msg)
        showFilters.value = false
      } else {
        showToast('info', 'No se encontraron condonaciones con los criterios especificados')
      }
    } else {
      error.value = response.data.eResponse?.message || 'Error en la búsqueda'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = err.response?.data?.message || 'Error al buscar condonaciones'
    console.error('Error al buscar condonaciones:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  form.value = {
    oficina: '',
    num_mercado: '',
    seccion: '',
    local: '',
    letra_local: '',
    bloque: ''
  }
  mercados.value = []
  localInfo.value = null
  condonaciones.value = []
  searched.value = false
  error.value = ''
  showToast('info', 'Filtros limpiados')
}

const exportarExcel = () => {
  if (condonaciones.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }
  // TODO: Implementar exportación a Excel
  showToast('info', 'Funcionalidad de exportación Excel en desarrollo')
}

const imprimir = () => {
  if (condonaciones.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }
  // TODO: Implementar impresión
  showToast('info', 'Funcionalidad de impresión en desarrollo')
}
</script>

<style scoped>
/* Los estilos están definidos en municipal-theme.css */
.empty-icon {
  color: #ccc;
  margin-bottom: 1rem;
}

.text-end {
  text-align: right;
}

.spinner-border {
  width: 3rem;
  height: 3rem;
}

.required {
  color: #dc3545;
}
</style>
