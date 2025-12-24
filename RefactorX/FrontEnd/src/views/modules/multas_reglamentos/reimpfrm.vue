<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="print" />
      </div>
      <div class="module-view-info">
        <h1>Reimpresión de Documentos</h1>
        <p>Reimprimir multas, recibos y documentos fiscales</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de reimpresión -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>🖨️ Datos para Reimpresión</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Documento *</label>
              <select class="municipal-form-control" v-model="filtros.tipo_documento">
                <option value="">Seleccione...</option>
                <option value="multa">Multa</option>
                <option value="recibo">Recibo de Pago</option>
                <option value="requerimiento">Requerimiento</option>
                <option value="acta">Acta Administrativa</option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Folio / ID (opcional)</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.folio"
                placeholder="Deja vacío para buscar todos"
                min="1"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Dependencia</label>
              <select class="municipal-form-control" v-model="filtros.id_dependencia">
                <option value="">Todas</option>
                <option value="3">3 - Tránsito</option>
                <option value="7">7 - Reglamentos</option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Formato de Impresión</label>
              <select class="municipal-form-control" v-model="filtros.formato">
                <option value="original">Original</option>
                <option value="copia">Copia</option>
                <option value="duplicado">Duplicado</option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filtros.tipo_documento"
              @click="reimprimir"
            >
              <font-awesome-icon icon="search" v-if="!loading" />
              <span v-if="loading">Buscando...</span>
              <span v-else>Buscar</span>
            </button>

            <button
              class="btn-municipal-secondary"
              @click="limpiar"
              :disabled="loading"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>

          <div class="help-text">
            <small>* Campos requeridos</small>
          </div>
        </div>
      </div>

      <!-- Mensaje de éxito -->
      <div class="municipal-card" v-if="success">
        <div class="municipal-card-body">
          <div class="alert alert-success">
            <strong>✅ Éxito:</strong> {{ success }}
          </div>
        </div>
      </div>

      <!-- Mensaje de error -->
      <div class="municipal-card" v-if="error">
        <div class="municipal-card-body">
          <div class="alert alert-danger">
            <strong>❌ Error:</strong> {{ error }}
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="todosResultados.length > 0">
        <div class="municipal-card-header">
          <h5>📄 Documentos Encontrados ({{ todosResultados.length }} registros)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Folio</th>
                  <th>Tipo</th>
                  <th>Fecha</th>
                  <th>Contribuyente</th>
                  <th>Dep.</th>
                  <th>Año Acta</th>
                  <th>Num Acta</th>
                  <th>Importe</th>
                  <th>Estatus</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in resultadosPaginados" :key="idx" class="row-hover">
                  <td style="font-weight: 600;">{{ row.folio }}</td>
                  <td>{{ row.tipo_documento }}</td>
                  <td>{{ formatDate(row.fecha) }}</td>
                  <td>{{ row.contribuyente }}</td>
                  <td>{{ row.dependencia }}</td>
                  <td>{{ row.axo_acta }}</td>
                  <td>{{ row.num_acta }}</td>
                  <td>{{ formatCurrency(row.importe) }}</td>
                  <td>
                    <span :class="getStatusClass(row.estatus)">
                      {{ row.estatus }}
                    </span>
                  </td>
                  <td>
                    <div class="action-buttons">
                      <button class="btn-action btn-preview-small" @click="verVistaPrevia(row)" title="Vista Previa">
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button class="btn-action btn-download-small" @click="descargarPDFDocumento(row)" title="Descargar PDF">
                        <font-awesome-icon icon="download" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ rangoInicio }}-{{ rangoFin }} de {{ todosResultados.length }} registros
            </div>

            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="paginaActual === 1"
                @click="cambiarPagina(1)"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button
                class="btn-pagination"
                :disabled="paginaActual === 1"
                @click="cambiarPagina(paginaActual - 1)"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <span class="pagination-text">
                Página {{ paginaActual }} de {{ totalPaginas }}
              </span>

              <button
                class="btn-pagination"
                :disabled="paginaActual === totalPaginas"
                @click="cambiarPagina(paginaActual + 1)"
              >
                <font-awesome-icon icon="angle-right" />
              </button>

              <button
                class="btn-pagination"
                :disabled="paginaActual === totalPaginas"
                @click="cambiarPagina(totalPaginas)"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div class="municipal-card" v-if="!loading && todosResultados.length === 0 && buscado">
        <div class="municipal-card-body">
          <div class="alert alert-info">
            <strong>Sin resultados:</strong> No se encontraron documentos con los criterios especificados.
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'reimpfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Reimpresión de Documentos'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'reimpfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Reimpresión de Documentos'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { usePdfGenerator } from '@/composables/usePdfGenerator'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_REIMPFRM'
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { verPDF, descargarPDF } = usePdfGenerator()

const filtros = ref({
  tipo_documento: 'multa',
  folio: null,
  id_dependencia: '',
  formato: 'original'
})

const todosResultados = ref([])
const paginaActual = ref(1)
const registrosPorPagina = 10
const success = ref(null)
const error = ref(null)
const buscado = ref(false)

// Computed para paginación
const totalPaginas = computed(() => {
  return Math.ceil(todosResultados.value.length / registrosPorPagina)
})

const resultadosPaginados = computed(() => {
  const inicio = (paginaActual.value - 1) * registrosPorPagina
  const fin = inicio + registrosPorPagina
  return todosResultados.value.slice(inicio, fin)
})

const rangoInicio = computed(() => {
  if (todosResultados.value.length === 0) return 0
  return (paginaActual.value - 1) * registrosPorPagina + 1
})

const rangoFin = computed(() => {
  const fin = paginaActual.value * registrosPorPagina
  return fin > todosResultados.value.length ? todosResultados.value.length : fin
})

async function reimprimir() {
  error.value = null
  success.value = null
  buscado.value = true
  paginaActual.value = 1

  if (!filtros.value.tipo_documento) {
    error.value = 'El tipo de documento es requerido'
    return
  }

  try {
    showLoading('Consultando...', 'Por favor espere')
    console.log('🖨️ Ejecutando búsqueda:', OP)
    console.log('🖨️ Filtros:', filtros.value)

    // Enviar parámetros en el formato correcto
    const params = [
      {
        nombre: 'p_folio',
        valor: filtros.value.folio || null,
        tipo: 'integer'
      },
      {
        nombre: 'p_tipo_documento',
        valor: filtros.value.tipo_documento,
        tipo: 'string'
      },
      {
        nombre: 'p_id_dependencia',
        valor: filtros.value.id_dependencia || null,
        tipo: 'integer'
      },
      {
        nombre: 'p_formato',
        valor: filtros.value.formato,
        tipo: 'string'
      }
    ]

    const data = await execute(OP, BASE_DB, params)

    console.log('✅ Resultado:', data)

    // Procesar respuesta
    let arr = []
    if (data && data.result && Array.isArray(data.result)) {
      arr = data.result
    } else if (Array.isArray(data)) {
      arr = data
    } else if (data && data.rows && Array.isArray(data.rows)) {
      arr = data.rows
    }

    todosResultados.value = arr

    if (arr.length > 0) {
      if (filtros.value.folio) {
        success.value = `Documento encontrado: ${filtros.value.tipo_documento.toUpperCase()} #${filtros.value.folio}`
      } else {
        success.value = `${arr.length} documentos encontrados`
      }
    } else {
      error.value = 'No se encontraron documentos con los criterios especificados'
    }

  } catch (e) {
    error.value = e.message || 'Error al buscar documentos'
    console.error('❌ Error:', e)
    todosResultados.value = []
  } finally {
    hideLoading()
  }
}

function limpiar() {
  filtros.value = {
    tipo_documento: 'multa',
    folio: null,
    id_dependencia: '',
    formato: 'original'
  }
  todosResultados.value = []
  paginaActual.value = 1
  success.value = null
  error.value = null
  buscado.value = false
}

function cambiarPagina(nuevaPagina) {
  if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas.value) {
    paginaActual.value = nuevaPagina
  }
}

function formatDate(dateString) {
  if (!dateString) return '-'
  const date = new Date(dateString)
  return date.toLocaleDateString('es-MX')
}

function formatCurrency(amount) {
  if (!amount && amount !== 0) return '-'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(amount)
}

function getStatusClass(status) {
  const statusLower = (status || '').toLowerCase()
  if (statusLower === 'pagado') return 'status-success'
  if (statusLower === 'pendiente') return 'status-warning'
  if (statusLower === 'cancelado') return 'status-danger'
  return 'status-info'
}

function verVistaPrevia(documento) {
  console.log('📄 Generando vista previa de documento:', documento)
  error.value = null
  try {
    verPDF(documento)
    console.log('✅ Vista previa generada exitosamente')
  } catch (e) {
    console.error('❌ Error al generar vista previa:', e)
    console.error('Documento recibido:', documento)
    error.value = `Error al generar vista previa del PDF: ${e.message}`
  }
}

function descargarPDFDocumento(documento) {
  console.log('⬇️ Descargando PDF de documento:', documento)
  error.value = null
  try {
    descargarPDF(documento)
    success.value = `PDF descargado: ${documento.tipo_documento}_${documento.folio}_${documento.axo_acta}.pdf`
    console.log('✅ PDF descargado exitosamente')
  } catch (e) {
    console.error('❌ Error al descargar PDF:', e)
    console.error('Documento recibido:', documento)
    error.value = `Error al descargar el PDF: ${e.message}`
  }
}

// Cargar documentos recientes al montar
onMounted(() => {
  reimprimir()
})
</script>

