<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="upload" /></div>
      <div class="module-view-info">
        <h1>Transacciones</h1>
        <p>Carga masiva desde archivo de texto</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-secondary" @click="mostrarDocumentacion" title="Documentacion Tecnica">
          <font-awesome-icon icon="file-code" /> Documentacion
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Seccion de Carga de Archivo -->
      <div class="form-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="file-upload" /></div>
          <div class="section-title-group">
            <h3>Cargar Archivo</h3>
            <span class="section-subtitle">Seleccione un archivo de texto con formato posicional</span>
          </div>
        </div>
        <div class="section-body">
          <div class="upload-area">
            <div class="form-field">
              <label class="municipal-form-label">Archivo de datos (.txt, .dat)</label>
              <div class="file-input-group">
                <input
                  type="file"
                  ref="fileInput"
                  class="municipal-form-control file-input"
                  accept=".txt,.dat"
                  @change="procesarArchivo"
                />
                <button class="btn-municipal-secondary" @click="limpiar" :disabled="registros.length === 0">
                  <font-awesome-icon icon="times" /> Limpiar
                </button>
              </div>
            </div>
            <div v-if="archivoNombre" class="file-info-box">
              <font-awesome-icon icon="file-alt" class="file-icon" />
              <div class="file-details">
                <strong>{{ archivoNombre }}</strong>
                <div class="file-stats">
                  <span class="stat-badge stat-success">
                    <font-awesome-icon icon="check-circle" /> {{ registros.length }} validos
                  </span>
                  <span v-if="registrosFiltrados > 0" class="stat-badge stat-warning">
                    <font-awesome-icon icon="filter" /> {{ registrosFiltrados }} filtrados
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Seccion de Registros -->
      <div class="form-section" v-if="registros.length > 0">
        <div class="section-header section-header-info">
          <div class="section-icon"><font-awesome-icon icon="table" /></div>
          <div class="section-title-group">
            <h3>Registros a Insertar</h3>
            <span class="section-subtitle">{{ registros.length }} registros listos para insercion</span>
          </div>
          <div class="section-actions">
            <button class="btn-municipal-success" @click="insertarRegistros" :disabled="insertando || registros.length === 0">
              <font-awesome-icon :icon="insertando ? 'spinner' : 'database'" :spin="insertando" />
              {{ insertando ? `Insertando... (${insertadosCount}/${registros.length})` : 'Insertar Todo' }}
            </button>
          </div>
        </div>
        <div class="section-body">
          <div class="table-responsive table-scroll">
            <table class="municipal-table table-sm">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Sector</th>
                  <th>Categ</th>
                  <th>Numero</th>
                  <th>Nombre</th>
                  <th>Telefono</th>
                  <th>Calle</th>
                  <th>Num</th>
                  <th>Cupo</th>
                  <th>F.Alta</th>
                  <th>F.Inicio</th>
                  <th>F.Venc</th>
                  <th>Zona</th>
                  <th>SubZ</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in registros" :key="idx" :class="getRowClass(r)">
                  <td>{{ idx + 1 }}</td>
                  <td>{{ r.cve_sector }}</td>
                  <td>{{ r.cve_categ }}</td>
                  <td><code class="numero-code">{{ r.cve_numero }}</code></td>
                  <td>{{ r.nombre }}</td>
                  <td>{{ r.telefono }}</td>
                  <td>{{ r.calle }}</td>
                  <td>{{ r.num }}</td>
                  <td>{{ r.cupo }}</td>
                  <td>{{ r.fecha_alta }}</td>
                  <td>{{ r.fecha_inic }}</td>
                  <td>{{ r.fecha_venci }}</td>
                  <td>{{ r.zona }}</td>
                  <td>{{ r.subzona }}</td>
                  <td>
                    <span v-if="r.insertado" class="status-badge status-success">
                      <font-awesome-icon icon="check" />
                    </span>
                    <span v-else-if="r.error" class="status-badge status-error">
                      <font-awesome-icon icon="times" />
                    </span>
                    <span v-else class="status-badge status-pending">
                      {{ r.estatus }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Seccion de Resultado -->
      <div class="form-section" v-if="resultadoInsercion">
        <div class="section-header" :class="resultadoInsercion.errores === 0 ? 'section-header-success' : 'section-header-warning'">
          <div class="section-icon"><font-awesome-icon icon="clipboard-check" /></div>
          <div class="section-title-group">
            <h3>Resultado de Insercion</h3>
            <span class="section-subtitle">Proceso completado</span>
          </div>
        </div>
        <div class="section-body">
          <div class="result-grid">
            <div class="result-card result-success">
              <font-awesome-icon icon="check-circle" class="result-icon" />
              <div class="result-content">
                <span class="result-value">{{ resultadoInsercion.exitosos }}</span>
                <span class="result-label">Insertados</span>
              </div>
            </div>
            <div class="result-card result-error">
              <font-awesome-icon icon="times-circle" class="result-icon" />
              <div class="result-content">
                <span class="result-value">{{ resultadoInsercion.errores }}</span>
                <span class="result-label">Errores</span>
              </div>
            </div>
            <div class="result-card result-total">
              <font-awesome-icon icon="info-circle" class="result-icon" />
              <div class="result-content">
                <span class="result-value">{{ resultadoInsercion.total }}</span>
                <span class="result-label">Total</span>
              </div>
            </div>
          </div>
          <div v-if="resultadoInsercion.mensajesError.length > 0" class="error-list">
            <h6><font-awesome-icon icon="exclamation-triangle" /> Errores detectados:</h6>
            <ul class="error-items">
              <li v-for="(msg, i) in resultadoInsercion.mensajesError.slice(0, 10)" :key="i">
                {{ msg }}
              </li>
              <li v-if="resultadoInsercion.mensajesError.length > 10" class="more-errors">
                ... y {{ resultadoInsercion.mensajesError.length - 10 }} errores mas
              </li>
            </ul>
          </div>
        </div>
      </div>

      <!-- Informacion de Formato -->
      <div class="form-section">
        <div class="section-header section-header-help">
          <div class="section-icon"><font-awesome-icon icon="info-circle" /></div>
          <div class="section-title-group">
            <h3>Formato del Archivo</h3>
            <span class="section-subtitle">Estructura del archivo de texto</span>
          </div>
        </div>
        <div class="section-body">
          <div class="format-grid">
            <div class="format-item"><span class="pos">1</span> Sector (1 car)</div>
            <div class="format-item"><span class="pos">2-3</span> Categoria (2 car)</div>
            <div class="format-item"><span class="pos">4-7</span> Numero (4 car)</div>
            <div class="format-item"><span class="pos">8-37</span> Nombre (30 car)</div>
            <div class="format-item"><span class="pos">38-44</span> Telefono (7 car)</div>
            <div class="format-item"><span class="pos">45-74</span> Calle (30 car)</div>
            <div class="format-item"><span class="pos">75-78</span> Num (4 car)</div>
            <div class="format-item"><span class="pos">79-82</span> Cupo (4 car)</div>
            <div class="format-item"><span class="pos">83-88</span> Fecha Alta (DDMMYY)</div>
            <div class="format-item"><span class="pos">89-94</span> Fecha Inicio (DDMMYY)</div>
            <div class="format-item"><span class="pos">95-100</span> Fecha Venc (DDMMYY)</div>
            <div class="format-item"><span class="pos">151</span> Zona (1 car)</div>
          </div>
          <div class="format-note">
            <font-awesome-icon icon="filter" /> Se filtran automaticamente registros con numero '9999' y estatus 'B'
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal :show="showDocumentation" @close="closeDocumentation" title="Ayuda - TransPublicos">
      <h3>Carga Masiva de Estacionamientos Publicos</h3>
      <p>Este modulo permite cargar estacionamientos desde un archivo de texto con formato posicional fijo.</p>
      <h4>Instrucciones:</h4>
      <ol>
        <li>Seleccione el archivo de texto con los datos</li>
        <li>Verifique que los registros se cargaron correctamente</li>
        <li>Presione "Insertar Todo" para procesar</li>
      </ol>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal :show="showTechDocs" :componentName="'TransPublicos'" :moduleName="'estacionamiento_publico'" @close="closeTechDocs" />
  </div>
</template>

<script setup>
import { ref, nextTick } from 'vue'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'

const { execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const fileInput = ref(null)
const archivoNombre = ref('')
const registros = ref([])
const registrosFiltrados = ref(0)
const insertando = ref(false)
const insertadosCount = ref(0)
const resultadoInsercion = ref(null)

function getRowClass(r) {
  if (r.insertado) return 'row-success'
  if (r.error) return 'row-error'
  return ''
}

function parsearLinea(linea, index) {
  if (linea.length < 154) return null

  const cve_numero = linea.substring(3, 7).trim()
  const estatus = linea.substring(153, 154).trim()

  if (cve_numero === '9999' || estatus === 'B') {
    return null
  }

  const parseFecha = (str) => {
    if (!str || str.trim() === '' || str === '000000') return null
    const dd = str.substring(0, 2)
    const mm = str.substring(2, 4)
    const yy = str.substring(4, 6)
    const year = parseInt(yy) > 50 ? '19' + yy : '20' + yy
    return `${dd}/${mm}/${year}`
  }

  return {
    cve_sector: linea.substring(0, 1).trim(),
    cve_categ: linea.substring(1, 3).trim(),
    cve_numero,
    nombre: linea.substring(7, 37).trim(),
    telefono: linea.substring(37, 44).trim(),
    calle: linea.substring(44, 74).trim(),
    num: linea.substring(74, 78).trim(),
    cupo: linea.substring(78, 82).trim(),
    fecha_alta: parseFecha(linea.substring(82, 88)),
    fecha_inic: parseFecha(linea.substring(88, 94)),
    fecha_venci: parseFecha(linea.substring(94, 100)),
    delas: linea.substring(100, 104).trim(),
    alas: linea.substring(104, 108).trim(),
    delas1: linea.substring(108, 112).trim(),
    alas1: linea.substring(112, 116).trim(),
    frec_lunes: linea.substring(116, 117).trim(),
    frec_martes: linea.substring(117, 118).trim(),
    frec_miercoles: linea.substring(118, 119).trim(),
    frec_jueves: linea.substring(119, 120).trim(),
    frec_viernes: linea.substring(120, 121).trim(),
    frec_sabado: linea.substring(121, 122).trim(),
    frec_domingo: linea.substring(122, 123).trim(),
    pol_num: linea.substring(123, 135).trim(),
    pol_fec_ven: parseFecha(linea.substring(135, 141)),
    numlic: linea.substring(141, 150).trim(),
    zona: linea.substring(150, 151).trim(),
    subzona: linea.substring(151, 153).trim(),
    estatus,
    clave: linea.substring(154, 155).trim(),
    control: 500 + index,
    insertado: false,
    error: false
  }
}

function procesarArchivo(event) {
  const file = event.target.files[0]
  if (!file) return

  archivoNombre.value = file.name
  registros.value = []
  registrosFiltrados.value = 0
  resultadoInsercion.value = null

  const reader = new FileReader()
  reader.onload = (e) => {
    const contenido = e.target.result
    const lineas = contenido.split('\n')

    let filtrados = 0
    const datos = []

    lineas.forEach((linea, idx) => {
      if (linea.trim().length > 0) {
        const registro = parsearLinea(linea, idx)
        if (registro) {
          datos.push(registro)
        } else {
          filtrados++
        }
      }
    })

    registros.value = datos
    registrosFiltrados.value = filtrados

    if (datos.length > 0) {
      showToast('success', `${datos.length} registros cargados correctamente`)
    } else {
      showToast('warning', 'No se encontraron registros validos en el archivo')
    }
  }

  reader.onerror = () => {
    showToast('error', 'Error al leer el archivo')
  }

  reader.readAsText(file)
}

async function insertarRegistros() {
  if (registros.value.length === 0) return

  hideLoading()
  await nextTick()

  const result = await Swal.fire({
    title: 'Confirmar Insercion',
    html: `<p>Esta a punto de insertar <strong>${registros.value.length}</strong> registros.</p>
           <p>Esta accion no se puede deshacer.</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Si, Insertar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d'
  })

  if (!result.isConfirmed) return

  insertando.value = true
  insertadosCount.value = 0

  showLoading('Insertando registros...', 'Por favor espere')

  const resultado = {
    exitosos: 0,
    errores: 0,
    total: registros.value.length,
    mensajesError: []
  }

  for (let i = 0; i < registros.value.length; i++) {
    const r = registros.value[i]

    try {
      const parametros = Object.entries(r)
        .filter(([key]) => !['insertado', 'error'].includes(key))
        .map(([nombre, valor]) => ({
          nombre,
          valor: valor ?? '',
          tipo: typeof valor === 'number' ? 'integer' : 'string'
        }))

      const resp = await execute('sp_ta_15_publicos_insert', BASE_DB, parametros, '', null, SCHEMA)

      if (resp?.success !== false) {
        r.insertado = true
        resultado.exitosos++
      } else {
        r.error = true
        resultado.errores++
        resultado.mensajesError.push(`Registro ${i + 1} (${r.cve_numero}): ${resp?.message || 'Error desconocido'}`)
      }
    } catch (e) {
      r.error = true
      resultado.errores++
      resultado.mensajesError.push(`Registro ${i + 1} (${r.cve_numero}): ${e.message || 'Error de conexion'}`)
    }

    insertadosCount.value = i + 1

    if (i % 10 === 0) {
      await new Promise(resolve => setTimeout(resolve, 0))
    }
  }

  resultadoInsercion.value = resultado
  insertando.value = false
  hideLoading()

  if (resultado.errores === 0) {
    showToast('success', `Se insertaron ${resultado.exitosos} registros correctamente`)
  } else {
    showToast('warning', `Completado con errores - Exitosos: ${resultado.exitosos}, Errores: ${resultado.errores}`)
  }
}

function limpiar() {
  registros.value = []
  archivoNombre.value = ''
  registrosFiltrados.value = 0
  resultadoInsercion.value = null
  insertadosCount.value = 0
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false
</script>

<style scoped>
/* Secciones */
.form-section {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  margin-bottom: 1.5rem;
  overflow: hidden;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.section-header-info {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
}

.section-header-success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
}

.section-header-warning {
  background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%);
}

.section-header-help {
  background: linear-gradient(135deg, #6c757d 0%, #495057 100%);
}

.section-icon {
  width: 40px;
  height: 40px;
  background: rgba(255,255,255,0.2);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
}

.section-title-group {
  flex: 1;
}

.section-title-group h3 {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
}

.section-subtitle {
  font-size: 0.85rem;
  opacity: 0.9;
}

.section-actions {
  margin-left: auto;
}

.section-body {
  padding: 1.5rem;
}

/* Upload area */
.upload-area {
  max-width: 600px;
}

.file-input-group {
  display: flex;
  gap: 1rem;
}

.file-input {
  flex: 1;
}

.file-info-box {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-top: 1rem;
  padding: 1rem;
  background: #e3f2fd;
  border-radius: 8px;
  border-left: 4px solid #1976d2;
}

.file-icon {
  font-size: 2rem;
  color: #1976d2;
}

.file-details {
  flex: 1;
}

.file-stats {
  display: flex;
  gap: 0.75rem;
  margin-top: 0.5rem;
}

.stat-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.85rem;
}

.stat-success {
  background: #d4edda;
  color: #155724;
}

.stat-warning {
  background: #fff3cd;
  color: #856404;
}

/* Table */
.table-scroll {
  max-height: 400px;
  overflow-y: auto;
}

.numero-code {
  background: #f8f9fa;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-family: 'Consolas', monospace;
  font-weight: 600;
}

.row-success {
  background: #d4edda !important;
}

.row-error {
  background: #f8d7da !important;
}

.status-badge {
  width: 24px;
  height: 24px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  font-size: 0.75rem;
}

.status-success {
  background: #28a745;
  color: white;
}

.status-error {
  background: #dc3545;
  color: white;
}

.status-pending {
  background: #e9ecef;
  color: #495057;
}

/* Results */
.result-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

@media (max-width: 768px) {
  .result-grid {
    grid-template-columns: 1fr;
  }
}

.result-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
  border-radius: 8px;
}

.result-success {
  background: #d4edda;
  border-left: 4px solid #28a745;
}

.result-error {
  background: #f8d7da;
  border-left: 4px solid #dc3545;
}

.result-total {
  background: #d1ecf1;
  border-left: 4px solid #17a2b8;
}

.result-icon {
  font-size: 2rem;
}

.result-success .result-icon { color: #28a745; }
.result-error .result-icon { color: #dc3545; }
.result-total .result-icon { color: #17a2b8; }

.result-value {
  font-size: 2rem;
  font-weight: 700;
  display: block;
}

.result-label {
  font-size: 0.9rem;
  color: #6c757d;
}

/* Error list */
.error-list {
  padding: 1rem;
  background: #fff3cd;
  border-radius: 8px;
  border-left: 4px solid #ffc107;
}

.error-list h6 {
  margin: 0 0 0.75rem;
  color: #856404;
}

.error-items {
  margin: 0;
  padding-left: 1.5rem;
}

.error-items li {
  margin-bottom: 0.5rem;
  color: #856404;
}

.more-errors {
  font-style: italic;
}

/* Format grid */
.format-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.format-item {
  padding: 0.5rem 0.75rem;
  background: #f8f9fa;
  border-radius: 4px;
  font-size: 0.9rem;
}

.format-item .pos {
  display: inline-block;
  background: #667eea;
  color: white;
  padding: 0.125rem 0.5rem;
  border-radius: 4px;
  margin-right: 0.5rem;
  font-family: 'Consolas', monospace;
  font-size: 0.8rem;
}

.format-note {
  padding: 0.75rem 1rem;
  background: #fff3cd;
  border-radius: 6px;
  color: #856404;
  font-size: 0.9rem;
}

.btn-municipal-success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
  border: none;
  color: white;
  padding: 0.5rem 1.5rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
}

.btn-municipal-success:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(40, 167, 69, 0.3);
}

.btn-municipal-success:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
</style>
