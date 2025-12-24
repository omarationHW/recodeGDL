<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Contratos</h1>
        <p>Aseo Contratado - Consulta y búsqueda de contratos</p>
      </div>
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Filtros de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Búsqueda</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Contrato</label>
              <input type="number" v-model="filtros.num_contrato" class="municipal-form-control"
                placeholder="Ingrese número de contrato" @keyup.enter="buscarContratos" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Aseo</label>
              <select v-model="filtros.tipo_aseo" class="municipal-form-control">
                <option value="T">Todos</option>
                <option v-for="tipo in tiposAseo" :key="tipo.tipo_aseo" :value="tipo.tipo_aseo">
                  {{ tipo.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Vigencia</label>
              <select v-model="filtros.vigencia" class="municipal-form-control">
                <option value="T">Todos</option>
                <option value="V">Vigente</option>
                <option value="N">Nuevo</option>
                <option value="B">Baja</option>
                <option value="C">Cancelado</option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="buscarContratos" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" /> Buscar
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div v-if="contratos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Contratos Encontrados ({{ contratos.length }})</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Contrato</th>
                  <th>Empresa</th>
                  <th>Representante</th>
                  <th>Tipo Aseo</th>
                  <th>Unidades</th>
                  <th>Domicilio</th>
                  <th>Status</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in contratos" :key="contrato.control_contrato" class="row-hover">
                  <td><strong>{{ contrato.num_contrato }}</strong></td>
                  <td>{{ contrato.nombre_empresa }}</td>
                  <td>{{ contrato.representante_empresa }}</td>
                  <td>{{ contrato.tipo_aseo_descripcion }}</td>
                  <td>{{ contrato.cantidad_recoleccion }} - {{ contrato.unidad_recoleccion }}</td>
                  <td>{{ getDomicilioCompleto(contrato) }}</td>
                  <td>
                    <span :class="['badge', getStatusClass(contrato.status_contrato)]">
                      {{ getStatusLabel(contrato.status_contrato) }}
                    </span>
                  </td>
                  <td>
                    <button class="btn-municipal-info btn-sm" @click="verDetalle(contrato)" title="Ver Detalle">
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div v-if="consultaRealizada && contratos.length === 0" class="municipal-card mt-3">
        <div class="municipal-card-body text-center py-5">
          <font-awesome-icon icon="inbox" size="3x" class="text-muted mb-3" />
          <p class="text-muted">No se encontraron contratos con los criterios especificados</p>
        </div>
      </div>
    </div>

    <!-- Modal de Detalle -->
    <div v-if="showDetalleModal" class="modal-overlay" @click="showDetalleModal = false">
      <div class="modal-container modal-lg" @click.stop>
        <div class="modal-header">
          <h5><font-awesome-icon icon="file-contract" /> Detalle del Contrato #{{ contratoSeleccionado.num_contrato }}</h5>
          <button class="modal-close" @click="showDetalleModal = false">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="modal-body">
          <div v-if="contratoSeleccionado">
            <h6 class="section-title"><font-awesome-icon icon="building" /> Información de la Empresa</h6>
            <div class="detail-grid">
              <div class="detail-item">
                <label class="detail-label">Empresa</label>
                <p class="detail-value">{{ contratoSeleccionado.nombre_empresa }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Representante</label>
                <p class="detail-value">{{ contratoSeleccionado.representante_empresa }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">RFC</label>
                <p class="detail-value">{{ contratoSeleccionado.rfc || 'N/A' }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">CURP</label>
                <p class="detail-value">{{ contratoSeleccionado.curp || 'N/A' }}</p>
              </div>
            </div>

            <h6 class="section-title mt-4"><font-awesome-icon icon="map-marker-alt" /> Domicilio</h6>
            <div class="detail-grid">
              <div class="detail-item">
                <label class="detail-label">Calle</label>
                <p class="detail-value">{{ contratoSeleccionado.calle }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Número Exterior</label>
                <p class="detail-value">{{ contratoSeleccionado.numext }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Número Interior</label>
                <p class="detail-value">{{ contratoSeleccionado.numint || 'N/A' }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Colonia</label>
                <p class="detail-value">{{ contratoSeleccionado.colonia }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Sector</label>
                <p class="detail-value">{{ contratoSeleccionado.sector || 'N/A' }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Código Postal</label>
                <p class="detail-value">{{ contratoSeleccionado.cp || 'N/A' }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Municipio</label>
                <p class="detail-value">{{ contratoSeleccionado.municipio }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Estado</label>
                <p class="detail-value">{{ contratoSeleccionado.estado }}</p>
              </div>
            </div>

            <h6 class="section-title mt-4"><font-awesome-icon icon="file-alt" /> Información del Contrato</h6>
            <div class="detail-grid">
              <div class="detail-item">
                <label class="detail-label">Número de Contrato</label>
                <p class="detail-value"><strong>{{ contratoSeleccionado.num_contrato }}</strong></p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Control de Contrato</label>
                <p class="detail-value">{{ contratoSeleccionado.control_contrato }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Tipo de Aseo</label>
                <p class="detail-value">{{ contratoSeleccionado.tipo_aseo_descripcion }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Status</label>
                <p class="detail-value">
                  <span :class="['badge', getStatusClass(contratoSeleccionado.status_contrato)]">
                    {{ getStatusLabel(contratoSeleccionado.status_contrato) }}
                  </span>
                </p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Unidad de Recolección</label>
                <p class="detail-value">{{ contratoSeleccionado.unidad_recoleccion }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Cantidad de Unidades</label>
                <p class="detail-value"><strong>{{ contratoSeleccionado.cantidad_recoleccion }}</strong></p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Inicio de Obligación</label>
                <p class="detail-value">{{ formatPeriodo(contratoSeleccionado.inicio_oblig) }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Fin de Obligación</label>
                <p class="detail-value">{{ formatPeriodo(contratoSeleccionado.fin_oblig) }}</p>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-municipal-secondary" @click="showDetalleModal = false">
            <font-awesome-icon icon="times" /> Cerrar
          </button>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Consulta de Contratos">
      <h3>Consulta de Contratos</h3>
      <p>Este módulo permite consultar y buscar contratos de aseo contratado según diversos criterios.</p>

      <h4>Filtros Disponibles:</h4>
      <ul>
        <li><strong>Número de Contrato:</strong> Buscar un contrato específico por su número</li>
        <li><strong>Tipo de Aseo:</strong> Filtrar por el tipo de servicio de aseo</li>
        <li><strong>Vigencia:</strong> Filtrar por el estado del contrato (Vigente, Nuevo, Baja, Cancelado)</li>
      </ul>

      <h4>Status de Contratos:</h4>
      <ul>
        <li><strong>Vigente (V):</strong> Contrato activo y en operación</li>
        <li><strong>Nuevo (N):</strong> Contrato recién registrado</li>
        <li><strong>Baja (B):</strong> Contrato dado de baja</li>
        <li><strong>Cancelado (C):</strong> Contrato cancelado</li>
      </ul>

      <h4>Funcionalidades:</h4>
      <ul>
        <li>Búsqueda rápida por número de contrato</li>
        <li>Filtrado múltiple por tipo y vigencia</li>
        <li>Vista detallada de cada contrato</li>
        <li>Información completa de empresa y domicilio</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const showDetalleModal = ref(false)
const contratoSeleccionado = ref(null)
const contratos = ref([])
const consultaRealizada = ref(false)
const tiposAseo = ref([])

const filtros = ref({
  num_contrato: null,
  tipo_aseo: 'T',
  vigencia: 'T'
})

const buscarContratos = async () => {
  loading.value = true
  consultaRealizada.value = true

  try {
    let response

    if (filtros.value.num_contrato) {
      // Búsqueda específica por número
      response = await execute('sp16_contratos_buscar', 'aseo_contratado', {
        parContrato: filtros.value.num_contrato,
        parTipo: filtros.value.tipo_aseo,
        parVigencia: filtros.value.vigencia
      })
    } else {
      // Búsqueda general
      response = await execute('sp16_contratos', 'aseo_contratado', {
        parTipo: filtros.value.tipo_aseo,
        parVigencia: filtros.value.vigencia
      })
    }

    if (response && response.data) {
      contratos.value = response.data

      if (contratos.value.length === 0) {
        showToast('No se encontraron contratos', 'info')
      }
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al buscar contratos', 'error')
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  filtros.value = {
    num_contrato: null,
    tipo_aseo: 'T',
    vigencia: 'T'
  }
  contratos.value = []
  consultaRealizada.value = false
}

const verDetalle = (contrato) => {
  contratoSeleccionado.value = contrato
  showDetalleModal.value = true
}

const cargarTiposAseo = async () => {
  try {
    const response = await execute('SP_ASEO_TIPOS_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 100,
      p_search: null
    })

    if (response && response.data) {
      tiposAseo.value = response.data
    }
  } catch (error) {
    console.error('Error al cargar tipos de aseo:', error)
  }
}

const getDomicilioCompleto = (contrato) => {
  const partes = [
    contrato.calle,
    contrato.numext,
    contrato.colonia
  ].filter(Boolean)

  return partes.join(', ')
}

const getStatusLabel = (status) => {
  const labels = {
    V: 'Vigente',
    N: 'Nuevo',
    B: 'Baja',
    C: 'Cancelado'
  }
  return labels[status] || status
}

const getStatusClass = (status) => {
  const classes = {
    V: 'badge-success',
    N: 'badge-info',
    B: 'badge-warning',
    C: 'badge-danger'
  }
  return classes[status] || 'badge-secondary'
}

const formatPeriodo = (periodo) => {
  if (!periodo) return 'N/A'

  // Formato: YYYY-MM
  const [year, month] = periodo.split('-')
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']

  return `${meses[parseInt(month) - 1]} ${year}`
}

const openDocumentation = () => {
  showDocumentation.value = true
}

onMounted(() => {
  cargarTiposAseo()
})
</script>

