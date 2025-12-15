<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="building" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Empresas</h1>
        <p>Aseo Contratado - Reporte de empresas con estadísticas de contratos</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros del Reporte</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Empresa</label>
              <select v-model="filtros.tipo_persona" class="municipal-form-control">
                <option value="">Todas</option>
                <option value="F">Física</option>
                <option value="M">Moral</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Status</label>
              <select v-model="filtros.status" class="municipal-form-control">
                <option value="">Todos</option>
                <option value="A">Activas</option>
                <option value="I">Inactivas</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Con Contratos</label>
              <select v-model="filtros.con_contratos" class="municipal-form-control">
                <option value="">Todas</option>
                <option value="SI">Solo con contratos</option>
                <option value="NO">Sin contratos</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Ordenar Por</label>
              <select v-model="filtros.orden" class="municipal-form-control">
                <option value="descripcion">Nombre Empresa</option>
                <option value="num_empresa">Número Empresa</option>
                <option value="contratos">Cantidad Contratos</option>
                <option value="unidades">Total Unidades</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Búsqueda</label>
              <input
                type="text"
                v-model="filtros.busqueda"
                class="municipal-form-control"
                placeholder="Buscar por nombre o RFC"
              />
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="generarReporte" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'file-chart-column'" :spin="loading" /> Generar Reporte
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
            <button v-if="reporteGenerado" class="btn-municipal-primary" @click="exportarExcel">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
            <button v-if="reporteGenerado" class="btn-municipal-secondary" @click="exportarPDF">
              <font-awesome-icon icon="file-pdf" /> PDF
            </button>
          </div>
        </div>
      </div>

      <div v-if="reporteGenerado" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="chart-bar" /> Resumen General</h5>
        </div>
        <div class="municipal-card-body">
          <div class="summary-grid">
            <div class="summary-card">
              <div class="summary-icon bg-primary"><font-awesome-icon icon="building" /></div>
              <div class="summary-info">
                <p class="summary-label">Total de Empresas</p>
                <p class="summary-value">{{ datos.length }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-success"><font-awesome-icon icon="check-circle" /></div>
              <div class="summary-info">
                <p class="summary-label">Empresas Activas</p>
                <p class="summary-value">{{ totales.activas }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-info"><font-awesome-icon icon="file-contract" /></div>
              <div class="summary-info">
                <p class="summary-label">Total Contratos</p>
                <p class="summary-value">{{ totales.total_contratos }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-warning"><font-awesome-icon icon="dumpster" /></div>
              <div class="summary-info">
                <p class="summary-label">Total Unidades</p>
                <p class="summary-value">{{ totales.total_unidades }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-secondary"><font-awesome-icon icon="user-tie" /></div>
              <div class="summary-info">
                <p class="summary-label">Personas Físicas</p>
                <p class="summary-value">{{ totales.fisicas }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-dark"><font-awesome-icon icon="building" /></div>
              <div class="summary-info">
                <p class="summary-label">Personas Morales</p>
                <p class="summary-value">{{ totales.morales }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-if="reporteGenerado && datos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="table" /> Detalle de Empresas ({{ datos.length }} registros)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>No.</th>
                  <th>Empresa</th>
                  <th>RFC</th>
                  <th>Tipo</th>
                  <th>Contacto</th>
                  <th>Teléfono</th>
                  <th class="text-center">Contratos</th>
                  <th class="text-center">Unidades</th>
                  <th class="text-center">Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="empresa in datos" :key="empresa.num_empresa">
                  <td><strong>{{ empresa.num_empresa }}</strong></td>
                  <td>{{ empresa.descripcion }}</td>
                  <td class="text-monospace">{{ empresa.rfc || 'N/A' }}</td>
                  <td>
                    <span class="badge" :class="empresa.tipo_persona === 'F' ? 'badge-info' : 'badge-primary'">
                      {{ empresa.tipo_persona === 'F' ? 'FÍSICA' : 'MORAL' }}
                    </span>
                  </td>
                  <td class="text-small">{{ empresa.contacto || 'N/A' }}</td>
                  <td>{{ formatTelefono(empresa.telefono) }}</td>
                  <td class="text-center">
                    <span class="badge badge-primary">{{ empresa.total_contratos || 0 }}</span>
                  </td>
                  <td class="text-center">
                    <span class="badge badge-warning">{{ empresa.total_unidades || 0 }}</span>
                  </td>
                  <td class="text-center">
                    <span class="badge" :class="empresa.status === 'A' ? 'badge-success' : 'badge-danger'">
                      {{ empresa.status === 'A' ? 'ACTIVA' : 'INACTIVA' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="reporteGenerado && datos.length === 0" class="municipal-card mt-3">
        <div class="municipal-card-body text-center py-5">
          <font-awesome-icon icon="inbox" size="3x" class="text-muted mb-3" />
          <p class="text-muted">No se encontraron empresas con los filtros seleccionados</p>
        </div>
      </div>

      <!-- Modal de Detalle de Empresa -->
      <div v-if="empresaDetalle" class="modal-overlay" @click="cerrarDetalle">
        <div class="modal-content" @click.stop>
          <div class="modal-header">
            <h5>Detalle de Empresa</h5>
            <button class="btn-close" @click="cerrarDetalle">&times;</button>
          </div>
          <div class="modal-body">
            <div class="info-grid">
              <div class="info-item">
                <strong>Número:</strong>
                <span>{{ empresaDetalle.num_empresa }}</span>
              </div>
              <div class="info-item">
                <strong>Empresa:</strong>
                <span>{{ empresaDetalle.descripcion }}</span>
              </div>
              <div class="info-item">
                <strong>RFC:</strong>
                <span>{{ empresaDetalle.rfc || 'N/A' }}</span>
              </div>
              <div class="info-item">
                <strong>CURP:</strong>
                <span>{{ empresaDetalle.curp || 'N/A' }}</span>
              </div>
              <div class="info-item">
                <strong>Tipo Persona:</strong>
                <span>{{ empresaDetalle.tipo_persona === 'F' ? 'Física' : 'Moral' }}</span>
              </div>
              <div class="info-item">
                <strong>Contacto:</strong>
                <span>{{ empresaDetalle.contacto || 'N/A' }}</span>
              </div>
              <div class="info-item">
                <strong>Teléfono:</strong>
                <span>{{ formatTelefono(empresaDetalle.telefono) }}</span>
              </div>
              <div class="info-item">
                <strong>Email:</strong>
                <span>{{ empresaDetalle.email || 'N/A' }}</span>
              </div>
            </div>

            <h6 class="mt-4">Contratos de la Empresa</h6>
            <div v-if="empresaDetalle.contratos && empresaDetalle.contratos.length > 0">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Contrato</th>
                    <th>Tipo Aseo</th>
                    <th>Unidades</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="contrato in empresaDetalle.contratos" :key="contrato.num_contrato">
                    <td>{{ contrato.num_contrato }}</td>
                    <td>{{ formatTipoAseo(contrato.tipo_aseo) }}</td>
                    <td>{{ contrato.cantidad_recoleccion }}</td>
                    <td>
                      <span class="badge" :class="contrato.status_contrato === 'N' ? 'badge-success' : 'badge-danger'">
                        {{ contrato.status_contrato === 'N' ? 'ACTIVO' : 'INACTIVO' }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-else class="text-center text-muted py-3">
              Sin contratos registrados
            </div>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Reporte de Empresas">
      <h3>Reporte de Empresas</h3>
      <p>Genera un reporte completo de todas las empresas registradas en el sistema, incluyendo estadísticas de sus contratos.</p>

      <h4>Filtros Disponibles:</h4>
      <ul>
        <li><strong>Tipo de Empresa:</strong> Persona Física o Moral</li>
        <li><strong>Status:</strong> Activas o Inactivas</li>
        <li><strong>Con Contratos:</strong> Filtrar empresas con o sin contratos</li>
        <li><strong>Búsqueda:</strong> Por nombre de empresa o RFC</li>
        <li><strong>Ordenamiento:</strong> Por nombre, número, cantidad de contratos o unidades</li>
      </ul>

      <h4>Información Mostrada:</h4>
      <ul>
        <li>Número de empresa</li>
        <li>Nombre o razón social</li>
        <li>RFC y CURP (cuando aplique)</li>
        <li>Tipo de persona (Física/Moral)</li>
        <li>Datos de contacto (nombre, teléfono, email)</li>
        <li>Cantidad total de contratos</li>
        <li>Total de unidades contratadas</li>
        <li>Status de la empresa</li>
      </ul>

      <h4>Resumen Estadístico:</h4>
      <p>El reporte incluye un resumen con:</p>
      <ul>
        <li>Total de empresas registradas</li>
        <li>Empresas activas e inactivas</li>
        <li>Total de contratos y unidades</li>
        <li>Distribución por tipo de persona</li>
      </ul>

      <h4>Detalle de Empresa:</h4>
      <p>Haga clic en cualquier registro para ver el detalle completo de la empresa, incluyendo todos sus contratos.</p>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Rpt_Empresas'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const showDocumentation = ref(false)
const reporteGenerado = ref(false)
const datos = ref([])
const empresaDetalle = ref(null)

const filtros = ref({
  tipo_persona: '',
  status: '',
  con_contratos: '',
  busqueda: '',
  orden: 'descripcion'
})

const totales = computed(() => {
  const activas = datos.value.filter(e => e.status === 'A').length
  const fisicas = datos.value.filter(e => e.tipo_persona === 'F').length
  const morales = datos.value.filter(e => e.tipo_persona === 'M').length
  const total_contratos = datos.value.reduce((sum, e) => sum + parseInt(e.total_contratos || 0), 0)
  const total_unidades = datos.value.reduce((sum, e) => sum + parseInt(e.total_unidades || 0), 0)

  return {
    activas,
    fisicas,
    morales,
    total_contratos,
    total_unidades
  }
})

const generarReporte = async () => {
  showLoading()
  try {
    // 1. Obtener todas las empresas
    const responseEmpresas = await execute('SP_ASEO_EMPRESAS_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 10000,
      p_search: filtros.value.busqueda || null
    })

    let empresas = responseEmpresas || []

    // 2. Obtener todos los contratos para calcular estadísticas
    const responseContratos = await execute('sp16_contratos', 'aseo_contratado', {
      parTipo: 'T',
      parVigencia: 'T'
    })

    const contratos = responseContratos || []

    // 3. Calcular estadísticas por empresa
    empresas = empresas.map(empresa => {
      const contratosEmpresa = contratos.filter(c => c.num_empresa === empresa.num_empresa)
      const total_contratos = contratosEmpresa.length
      const total_unidades = contratosEmpresa.reduce((sum, c) => sum + parseInt(c.cantidad_recoleccion || 0), 0)

      return {
        ...empresa,
        total_contratos,
        total_unidades,
        contratos: contratosEmpresa
      }
    })

    // 4. Aplicar filtros
    if (filtros.value.tipo_persona) {
      empresas = empresas.filter(e => e.tipo_persona === filtros.value.tipo_persona)
    }

    if (filtros.value.status) {
      empresas = empresas.filter(e => e.status === filtros.value.status)
    }

    if (filtros.value.con_contratos === 'SI') {
      empresas = empresas.filter(e => e.total_contratos > 0)
    } else if (filtros.value.con_contratos === 'NO') {
      empresas = empresas.filter(e => e.total_contratos === 0)
    }

    // 5. Ordenar
    empresas.sort((a, b) => {
      switch (filtros.value.orden) {
        case 'descripcion':
          return (a.descripcion || '').localeCompare(b.descripcion || '')
        case 'num_empresa':
          return parseInt(a.num_empresa) - parseInt(b.num_empresa)
        case 'contratos':
          return b.total_contratos - a.total_contratos
        case 'unidades':
          return b.total_unidades - a.total_unidades
        default:
          return 0
      }
    })

    datos.value = empresas
    reporteGenerado.value = true
    showToast(`Reporte generado: ${empresas.length} empresas encontradas`, 'success')
  } catch (error) {
    hideLoading()
    showToast('Error al generar reporte', 'error')
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const limpiarFiltros = () => {
  filtros.value = {
    tipo_persona: '',
    status: '',
    con_contratos: '',
    busqueda: '',
    orden: 'descripcion'
  }
  datos.value = []
  reporteGenerado.value = false
}

const verDetalle = (empresa) => {
  empresaDetalle.value = empresa
}

const cerrarDetalle = () => {
  empresaDetalle.value = null
}

const exportarExcel = () => {
  showToast('Exportación a Excel en desarrollo', 'info')
}

const exportarPDF = () => {
  showToast('Exportación a PDF en desarrollo', 'info')
}

const formatTelefono = (tel) => {
  if (!tel) return 'N/A'
  return tel
}

const formatTipoAseo = (tipo) => {
  const tipos = {
    'C': 'Comercial',
    'R': 'Residencial',
    'I': 'Industrial',
    'M': 'Mixto'
  }
  return tipos[tipo] || tipo
}

const openDocumentation = () => {
  showDocumentation.value = true
}
</script>

