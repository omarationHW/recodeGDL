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

    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando operación...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { usePdfGenerator } from '@/composables/usePdfGenerator'

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_REIMPFRM'
const { loading, execute } = useApi()
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

<style scoped>
.municipal-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 20px;
}

.municipal-card-header {
  padding: 15px 20px;
  border-bottom: 1px solid #e0e0e0;
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
  font-weight: bold;
  border-radius: 8px 8px 0 0;
}

.municipal-card-header h5 {
  margin: 0;
  color: white;
}

.municipal-card-body {
  padding: 20px;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 15px;
  margin-bottom: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.municipal-form-label {
  font-weight: 600;
  margin-bottom: 5px;
  color: #333;
}

.municipal-form-control {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.button-group {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

.btn-municipal-secondary {
  background: #6c757d;
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background: #5a6268;
  transform: translateY(-1px);
}

.btn-municipal-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.help-text {
  margin-top: 10px;
  color: #666;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
  margin-bottom: 20px;
}

.info-item {
  display: flex;
  flex-direction: column;
  padding: 10px;
  background: #f8f9fa;
  border-radius: 4px;
  border-left: 3px solid #ea8215;
}

.info-item strong {
  color: #666;
  font-size: 0.85rem;
  margin-bottom: 5px;
}

.info-item span {
  color: #333;
  font-size: 1rem;
  font-weight: 500;
}

.status-success {
  color: #28a745 !important;
  font-weight: 600 !important;
}

.status-warning {
  color: #ffc107 !important;
  font-weight: 600 !important;
}

.status-danger {
  color: #dc3545 !important;
  font-weight: 600 !important;
}

.status-info {
  color: #17a2b8 !important;
  font-weight: 600 !important;
}

.preview-actions {
  display: flex;
  gap: 10px;
  padding-top: 15px;
  border-top: 2px solid #ea8215;
}

.btn-preview,
.btn-download {
  flex: 1;
  padding: 12px;
  border: 2px solid #ea8215;
  background: white;
  color: #ea8215;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.btn-preview:hover,
.btn-download:hover {
  background: #ea8215;
  color: white;
  transform: translateY(-2px);
}

.alert {
  padding: 12px 20px;
  border-radius: 4px;
  margin-bottom: 15px;
}

.alert-success {
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  color: #155724;
}

.alert-danger {
  background-color: #f8d7da;
  border: 1px solid #f5c2c7;
  color: #842029;
}

.alert-info {
  background-color: #cfe2ff;
  border: 1px solid #b6d4fe;
  color: #084298;
}

.municipal-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

.municipal-table-header {
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
}

.municipal-table th,
.municipal-table td {
  padding: 10px;
  border: 1px solid #ddd;
  text-align: left;
  font-size: 0.9rem;
}

.municipal-table th {
  font-weight: bold;
  color: white;
}

.row-hover:hover {
  background-color: #f9f9f9;
}

.table-responsive {
  overflow-x: auto;
}

.action-buttons {
  display: flex;
  gap: 5px;
  justify-content: center;
}

.btn-action {
  background: white;
  border: 1px solid #ea8215;
  color: #ea8215;
  padding: 5px 10px;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.85rem;
}

.btn-action:hover {
  background: #ea8215;
  color: white;
  transform: translateY(-1px);
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 15px;
  border-top: 2px solid #ea8215;
}

.pagination-info {
  color: #666;
  font-size: 0.9rem;
}

.pagination-controls {
  display: flex;
  gap: 8px;
  align-items: center;
}

.btn-pagination {
  background: white;
  border: 1px solid #ddd;
  padding: 6px 12px;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s ease;
  color: #ea8215;
}

.btn-pagination:hover:not(:disabled) {
  background: #ea8215;
  color: white;
  border-color: #ea8215;
}

.btn-pagination:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.pagination-text {
  color: #333;
  font-weight: 600;
  padding: 0 10px;
}
</style>
