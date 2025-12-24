<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="exchange-alt" /></div>
      <div class="module-view-info">
        <h1>Transferencia de Folios</h1>
        <p>Altas/Bajas masivas de multas y calcomanias</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Seccion de Seleccion de Operacion -->
      <div class="form-section">
        <div class="section-header header-with-badge">
          <div class="section-icon"><font-awesome-icon icon="tasks" /></div>
          <div class="section-title-group">
            <h3>Seleccionar Operacion</h3>
            <span class="section-subtitle">Elija el tipo de transaccion a realizar</span>
          </div>
        </div>
        <div class="section-body">
          <div class="operation-cards">
            <div
              class="operation-card row-hover"
              :class="{ active: operacion === 'A', 'table-row-selected': operacion === 'A' }"
              @click="seleccionarOperacion('A')"
            >
              <div class="op-icon op-altas empty-state-icon"><font-awesome-icon icon="plus-circle" /></div>
              <div class="op-content">
                <strong>A - Altas de Multas</strong>
                <p>Insertar folios de multas de estacionometros</p>
              </div>
            </div>
            <div
              class="operation-card row-hover"
              :class="{ active: operacion === 'B', 'table-row-selected': operacion === 'B' }"
              @click="seleccionarOperacion('B')"
            >
              <div class="op-icon op-bajas empty-state-icon"><font-awesome-icon icon="minus-circle" /></div>
              <div class="op-content">
                <strong>B - Bajas de Multas</strong>
                <p>Dar de baja folios de multas existentes</p>
              </div>
            </div>
            <div
              class="operation-card row-hover"
              :class="{ active: operacion === 'C', 'table-row-selected': operacion === 'C' }"
              @click="seleccionarOperacion('C')"
            >
              <div class="op-icon op-calco empty-state-icon"><font-awesome-icon icon="id-card" /></div>
              <div class="op-content">
                <strong>C - Altas de Calcomanias</strong>
                <p>Insertar calcomanias sin propietario</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Seccion de Carga de Archivo (solo si hay operacion seleccionada) -->
      <div class="form-section" v-if="operacion">
        <div class="section-header section-header-info header-with-badge">
          <div class="section-icon empty-state-icon"><font-awesome-icon icon="file-upload" /></div>
          <div class="section-title-group">
            <h3>Cargar Archivo de Datos</h3>
            <span class="section-subtitle">{{ getOperacionTitulo() }}</span>
          </div>
        </div>
        <div class="section-body">
          <div class="upload-row">
            <div class="file-upload-area">
              <input
                type="file"
                ref="fileInput"
                class="municipal-form-control"
                accept=".txt,.dat,.csv"
                @change="procesarArchivo"
              />
              <button class="btn-municipal-secondary" @click="limpiarDatos" :disabled="registros.length === 0">
                <font-awesome-icon icon="times" /> Limpiar
              </button>
            </div>
            <!-- Checkbox para opcion B -->
            <div v-if="operacion === 'B'" class="option-checkbox">
              <label class="checkbox-container">
                <input type="checkbox" v-model="usarFechaArchivo" />
                <span class="checkmark"></span>
                Usar fecha del archivo para la baja
              </label>
            </div>
          </div>

          <!-- Info del archivo cargado -->
          <div v-if="archivoNombre" class="file-info-box">
            <font-awesome-icon icon="file-alt" class="file-icon empty-state-icon" />
            <div class="file-details">
              <strong>{{ archivoNombre }}</strong>
              <div class="file-stats">
                <span class="stat-badge stat-success">
                  <font-awesome-icon icon="check-circle" /> {{ registros.length }} registros
                </span>
                <span v-if="registrosError > 0" class="stat-badge stat-warning">
                  <font-awesome-icon icon="exclamation-triangle" /> {{ registrosError }} con errores
                </span>
              </div>
            </div>
          </div>

          <!-- Formato esperado -->
          <div class="format-help">
            <h6><font-awesome-icon icon="info-circle" /> Formato del archivo:</h6>
            <div class="format-grid" v-if="operacion === 'A'">
              <span class="format-item"><code>Col 5-8</code> Ano</span>
              <span class="format-item"><code>Col 41-47</code> Folio</span>
              <span class="format-item"><code>Col 10-16</code> Placa</span>
              <span class="format-item"><code>Col 30-39</code> Fecha (DDMMYYYY)</span>
              <span class="format-item"><code>Col 49</code> Infraccion</span>
            </div>
            <div class="format-grid" v-else-if="operacion === 'B'">
              <span class="format-item"><code>Col 1-4</code> Ano</span>
              <span class="format-item"><code>Col 6-12</code> Folio</span>
              <span class="format-item"><code>Col 25-31</code> Placa</span>
              <span class="format-item" v-if="usarFechaArchivo"><code>Col 33-42</code> Fecha</span>
            </div>
            <div class="format-grid" v-else-if="operacion === 'C'">
              <span class="format-item"><code>Col 1-6</code> Calcomania</span>
              <span class="format-item"><code>Col 8</code> Tipo</span>
              <span class="format-item"><code>Col 10</code> Turno</span>
              <span class="format-item"><code>Col 12-21</code> Fecha Inicial</span>
              <span class="format-item"><code>Col 23-32</code> Fecha Final</span>
              <span class="format-item"><code>Col 34-40</code> Placa</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Seccion de Tabla de Registros -->
      <div class="form-section" v-if="registros.length > 0">
        <div class="section-header header-with-badge" :class="getSectionHeaderClass()">
          <div class="section-icon empty-state-icon"><font-awesome-icon icon="table" /></div>
          <div class="section-title-group">
            <h3>Registros a Procesar</h3>
            <span class="section-subtitle">{{ registros.length }} registros cargados</span>
          </div>
          <div class="section-actions">
            <button
              class="btn-municipal-success"
              @click="procesarRegistros"
              :disabled="procesando || registros.length === 0"
            >
              <font-awesome-icon :icon="procesando ? 'spinner' : 'play'" :spin="procesando" />
              {{ procesando ? `Procesando (${procesadosCount}/${registros.length})` : 'Procesar Todo' }}
            </button>
          </div>
        </div>
        <div class="section-body">
          <div class="table-responsive table-scroll">
            <!-- Tabla para Altas (A) -->
            <table v-if="operacion === 'A'" class="municipal-table table-sm">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Ano</th>
                  <th>Folio</th>
                  <th>Placa</th>
                  <th>Fecha</th>
                  <th>Infraccion</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in registros" :key="idx" :class="getRowClass(r)" class="row-hover">
                  <td>{{ idx + 1 }}</td>
                  <td>{{ r.axo }}</td>
                  <td><code class="folio-code">{{ r.folio }}</code></td>
                  <td>{{ r.placa }}</td>
                  <td>{{ r.fecha }}</td>
                  <td>{{ r.infraccion }}</td>
                  <td><span :class="getStatusClass(r)"><font-awesome-icon :icon="getStatusIcon(r)" /></span></td>
                </tr>
              </tbody>
            </table>

            <!-- Tabla para Bajas (B) -->
            <table v-if="operacion === 'B'" class="municipal-table table-sm">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Ano</th>
                  <th>Folio</th>
                  <th>Placa</th>
                  <th v-if="usarFechaArchivo">Fecha</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in registros" :key="idx" :class="getRowClass(r)" class="row-hover">
                  <td>{{ idx + 1 }}</td>
                  <td>{{ r.axo }}</td>
                  <td><code class="folio-code">{{ r.folio }}</code></td>
                  <td>{{ r.placa }}</td>
                  <td v-if="usarFechaArchivo">{{ r.fecha }}</td>
                  <td><span :class="getStatusClass(r)"><font-awesome-icon :icon="getStatusIcon(r)" /></span></td>
                </tr>
              </tbody>
            </table>

            <!-- Tabla para Calcomanias (C) -->
            <table v-if="operacion === 'C'" class="municipal-table table-sm">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Calcomania</th>
                  <th>Tipo</th>
                  <th>Turno</th>
                  <th>Fecha Inicio</th>
                  <th>Fecha Fin</th>
                  <th>Placa</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in registros" :key="idx" :class="getRowClass(r)" class="row-hover">
                  <td>{{ idx + 1 }}</td>
                  <td><code class="folio-code">{{ r.calco }}</code></td>
                  <td>{{ r.tipo }}</td>
                  <td>{{ r.turno }}</td>
                  <td>{{ r.fecini }}</td>
                  <td>{{ r.fecfin }}</td>
                  <td>{{ r.placa }}</td>
                  <td><span :class="getStatusClass(r)"><font-awesome-icon :icon="getStatusIcon(r)" /></span></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Seccion de Resultado -->
      <div class="form-section" v-if="resultado">
        <div class="section-header header-with-badge" :class="resultado.errores === 0 ? 'section-header-success' : 'section-header-warning'">
          <div class="section-icon empty-state-icon"><font-awesome-icon icon="clipboard-check" /></div>
          <div class="section-title-group">
            <h3>Resultado del Proceso</h3>
            <span class="section-subtitle">{{ getOperacionTitulo() }}</span>
          </div>
        </div>
        <div class="section-body">
          <div class="result-grid">
            <div class="result-card result-success">
              <font-awesome-icon icon="check-circle" class="result-icon empty-state-icon" />
              <div class="result-content">
                <span class="result-value">{{ resultado.exitosos }}</span>
                <span class="result-label">Exitosos</span>
              </div>
            </div>
            <div class="result-card result-error">
              <font-awesome-icon icon="times-circle" class="result-icon empty-state-icon" />
              <div class="result-content">
                <span class="result-value">{{ resultado.errores }}</span>
                <span class="result-label">Errores</span>
              </div>
            </div>
            <div class="result-card result-total">
              <font-awesome-icon icon="info-circle" class="result-icon empty-state-icon" />
              <div class="result-content">
                <span class="result-value">{{ resultado.total }}</span>
                <span class="result-label">Total</span>
              </div>
            </div>
          </div>
          <div v-if="resultado.mensajesError.length > 0" class="error-list">
            <h6><font-awesome-icon icon="exclamation-triangle" /> Errores detectados:</h6>
            <ul class="error-items">
              <li v-for="(msg, i) in resultado.mensajesError.slice(0, 10)" :key="i">{{ msg }}</li>
              <li v-if="resultado.mensajesError.length > 10" class="more-errors">
                ... y {{ resultado.mensajesError.length - 10 }} errores mas
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'TransFoliosPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Transferencia de Folios'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import { ref, nextTick } from 'vue'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'

const { execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const operacion = ref('')
const fileInput = ref(null)
const archivoNombre = ref('')
const registros = ref([])
const registrosError = ref(0)
const usarFechaArchivo = ref(false)
const procesando = ref(false)
const procesadosCount = ref(0)
const resultado = ref(null)

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

function seleccionarOperacion(op) {
  operacion.value = op
  limpiarDatos()
}

function getOperacionTitulo() {
  switch (operacion.value) {
    case 'A': return 'Altas de Multas de Estacionometros'
    case 'B': return 'Bajas de Multas de Estacionometros'
    case 'C': return 'Altas de Calcomanias sin Propietario'
    default: return ''
  }
}

function getSectionHeaderClass() {
  switch (operacion.value) {
    case 'A': return 'section-header-altas'
    case 'B': return 'section-header-bajas'
    case 'C': return 'section-header-calco'
    default: return ''
  }
}

function limpiarDatos() {
  registros.value = []
  registrosError.value = 0
  archivoNombre.value = ''
  resultado.value = null
  procesadosCount.value = 0
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

function parseFecha(str) {
  if (!str || str.trim() === '' || str === '00000000') return null
  try {
    // Formato DDMMYYYY
    if (str.length >= 8) {
      const dd = str.substring(0, 2)
      const mm = str.substring(2, 4)
      const yyyy = str.substring(4, 8)
      return `${yyyy}-${mm}-${dd}`
    }
    // Formato DD/MM/YYYY
    if (str.includes('/')) {
      const parts = str.split('/')
      if (parts.length === 3) {
        return `${parts[2]}-${parts[1]}-${parts[0]}`
      }
    }
  } catch {
    return null
  }
  return null
}

function parsearLineaA(linea, idx) {
  // Opcion A: Altas de Multas
  // Col 5-8: Ano, Col 41-47: Folio, Col 10-16: Placa, Col 30-39: Fecha, Col 49: Infraccion
  if (linea.length < 50) return null

  try {
    const axo = parseInt(linea.substring(4, 8).trim()) || new Date().getFullYear()
    const folio = parseInt(linea.substring(40, 47).trim()) || 0
    const placa = linea.substring(9, 16).trim()
    const fechaStr = linea.substring(37, 39) + linea.substring(33, 37) + linea.substring(29, 33)
    const fecha = parseFecha(fechaStr)
    const infraccion = parseInt(linea.substring(48, 49).trim()) || 1

    if (folio === 0) return null

    return {
      axo,
      folio,
      placa,
      fecha,
      infraccion,
      procesado: false,
      error: false,
      mensaje: ''
    }
  } catch {
    return null
  }
}

function parsearLineaB(linea, idx) {
  // Opcion B: Bajas de Multas
  // Col 1-4: Ano, Col 6-12: Folio, Col 25-31: Placa, (opcional) Col 33-42: Fecha
  if (linea.length < 32) return null

  try {
    const axo = parseInt(linea.substring(0, 4).trim()) || new Date().getFullYear()
    const folio = parseInt(linea.substring(5, 12).trim()) || 0
    const placa = linea.substring(24, 31).trim()
    let fecha = null
    if (usarFechaArchivo.value && linea.length >= 43) {
      fecha = linea.substring(32, 42).trim()
      if (fecha.includes('/')) {
        const parts = fecha.split('/')
        if (parts.length === 3) {
          fecha = `${parts[2]}-${parts[1]}-${parts[0]}`
        }
      }
    }

    if (folio === 0) return null

    return {
      axo,
      folio,
      placa,
      fecha,
      procesado: false,
      error: false,
      mensaje: ''
    }
  } catch {
    return null
  }
}

function parsearLineaC(linea, idx) {
  // Opcion C: Altas de Calcomanias
  // Col 1-6: Calcomania, Col 8: Tipo, Col 10: Turno, Col 12-21: FechaIni, Col 23-32: FechaFin, Col 34-40: Placa
  if (linea.length < 40) return null

  try {
    const calco = parseInt(linea.substring(0, 6).trim()) || 0
    const tipo = linea.substring(7, 8).trim() || 'A'
    const turno = linea.substring(9, 10).trim() || 'M'
    const fecini = linea.substring(11, 21).trim()
    const fecfin = linea.substring(22, 32).trim()
    const placa = linea.substring(33, 40).trim()

    if (calco === 0) return null

    return {
      axo: new Date().getFullYear(),
      calco,
      tipo,
      turno,
      fecini: parseFecha(fecini.replace(/\//g, '')) || fecini,
      fecfin: parseFecha(fecfin.replace(/\//g, '')) || fecfin,
      placa,
      procesado: false,
      error: false,
      mensaje: ''
    }
  } catch {
    return null
  }
}

function procesarArchivo(event) {
  const file = event.target.files[0]
  if (!file) return

  archivoNombre.value = file.name
  registros.value = []
  registrosError.value = 0
  resultado.value = null

  const reader = new FileReader()
  reader.onload = (e) => {
    const contenido = e.target.result
    const lineas = contenido.split('\n')

    let errores = 0
    const datos = []

    lineas.forEach((linea, idx) => {
      if (linea.trim().length === 0) return

      let registro = null
      switch (operacion.value) {
        case 'A':
          registro = parsearLineaA(linea, idx)
          break
        case 'B':
          registro = parsearLineaB(linea, idx)
          break
        case 'C':
          registro = parsearLineaC(linea, idx)
          break
      }

      if (registro) {
        datos.push(registro)
      } else {
        errores++
      }
    })

    registros.value = datos
    registrosError.value = errores

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

async function procesarRegistros() {
  if (registros.value.length === 0) return

  hideLoading()
  await nextTick()

  const confirmResult = await Swal.fire({
    title: 'Confirmar Proceso',
    html: `<p>Esta a punto de procesar <strong>${registros.value.length}</strong> registros.</p>
           <p>Operacion: <strong>${getOperacionTitulo()}</strong></p>
           <p>Esta accion no se puede deshacer.</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Si, Procesar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  procesando.value = true
  procesadosCount.value = 0
  showLoading('Procesando registros...', 'Por favor espere')

  const res = {
    exitosos: 0,
    errores: 0,
    total: registros.value.length,
    mensajesError: []
  }

  for (let i = 0; i < registros.value.length; i++) {
    const r = registros.value[i]

    try {
      let params = []
      let spName = ''

      switch (operacion.value) {
        case 'A':
          spName = 'sp_transfolios_altas'
          params = [
            { nombre: 'p_axo', valor: r.axo, tipo: 'integer' },
            { nombre: 'p_folio', valor: r.folio, tipo: 'integer' },
            { nombre: 'p_placa', valor: r.placa, tipo: 'string' },
            { nombre: 'p_fecha', valor: r.fecha, tipo: 'string' },
            { nombre: 'p_infraccion', valor: r.infraccion, tipo: 'integer' }
          ]
          break

        case 'B':
          spName = 'sp_transfolios_bajas'
          params = [
            { nombre: 'p_axo', valor: r.axo, tipo: 'integer' },
            { nombre: 'p_folio', valor: r.folio, tipo: 'integer' },
            { nombre: 'p_placa', valor: r.placa, tipo: 'string' },
            { nombre: 'p_fecha', valor: r.fecha, tipo: 'string' },
            { nombre: 'p_usar_fecha_archivo', valor: usarFechaArchivo.value, tipo: 'boolean' }
          ]
          break

        case 'C':
          spName = 'sp_transfolios_calcomanias'
          params = [
            { nombre: 'p_axo', valor: r.axo, tipo: 'integer' },
            { nombre: 'p_calco', valor: r.calco, tipo: 'integer' },
            { nombre: 'p_status', valor: r.tipo, tipo: 'string' },
            { nombre: 'p_turno', valor: r.turno, tipo: 'string' },
            { nombre: 'p_fecini', valor: r.fecini, tipo: 'string' },
            { nombre: 'p_fecfin', valor: r.fecfin, tipo: 'string' },
            { nombre: 'p_placa', valor: r.placa, tipo: 'string' }
          ]
          break
      }

      const resp = await execute(spName, BASE_DB, params, '', null, SCHEMA)
      const data = resp?.result || resp?.data?.result || resp?.data || []
      const row = Array.isArray(data) ? data[0] : data

      if (row?.result === 1 || resp?.success !== false) {
        r.procesado = true
        r.error = false
        res.exitosos++
      } else {
        r.error = true
        r.mensaje = row?.msg || 'Error desconocido'
        res.errores++
        res.mensajesError.push(`Registro ${i + 1}: ${r.mensaje}`)
      }
    } catch (e) {
      r.error = true
      r.mensaje = e.message || 'Error de conexion'
      res.errores++
      res.mensajesError.push(`Registro ${i + 1}: ${r.mensaje}`)
    }

    procesadosCount.value = i + 1

    // Dar respiro al UI cada 10 registros
    if (i % 10 === 0) {
      await new Promise(resolve => setTimeout(resolve, 0))
    }
  }

  resultado.value = res
  procesando.value = false
  hideLoading()

  if (res.errores === 0) {
    showToast('success', `Se procesaron ${res.exitosos} registros correctamente`)
  } else {
    showToast('warning', `Completado con errores - Exitosos: ${res.exitosos}, Errores: ${res.errores}`)
  }
}

function getRowClass(r) {
  if (r.procesado) return 'row-success'
  if (r.error) return 'row-error'
  return ''
}

function getStatusClass(r) {
  if (r.procesado) return 'status-badge status-success'
  if (r.error) return 'status-badge status-error'
  return 'status-badge status-pending'
}

function getStatusIcon(r) {
  if (r.procesado) return 'check'
  if (r.error) return 'times'
  return 'clock'
}
</script>

<style scoped>
/* Secciones base */
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

.section-header-altas {
  background: linear-gradient(135deg, #28a745 0%, #218838 100%);
}

.section-header-bajas {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
}

.section-header-calco {
  background: linear-gradient(135deg, #6f42c1 0%, #5a32a3 100%);
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

/* Tarjetas de operacion */
.operation-cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
}

@media (max-width: 768px) {
  .operation-cards {
    grid-template-columns: 1fr;
  }
}

.operation-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.25rem;
  background: #f8f9fa;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.operation-card:hover {
  background: #fff;
  border-color: #667eea;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
}

.operation-card.active {
  background: #fff;
  border-color: #667eea;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.25);
}

.op-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  color: white;
}

.op-altas { background: linear-gradient(135deg, #28a745 0%, #20c997 100%); }
.op-bajas { background: linear-gradient(135deg, #dc3545 0%, #fd7e14 100%); }
.op-calco { background: linear-gradient(135deg, #6f42c1 0%, #764ba2 100%); }

.op-content strong {
  display: block;
  margin-bottom: 0.25rem;
}

.op-content p {
  margin: 0;
  font-size: 0.85rem;
  color: #6c757d;
}

/* Upload area */
.upload-row {
  display: flex;
  gap: 1.5rem;
  align-items: center;
  flex-wrap: wrap;
}

.file-upload-area {
  display: flex;
  gap: 1rem;
  flex: 1;
  min-width: 300px;
}

.file-upload-area input {
  flex: 1;
}

.option-checkbox {
  padding: 0.5rem 1rem;
  background: #fff3cd;
  border-radius: 6px;
  border-left: 3px solid #ffc107;
}

.checkbox-container {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
}

.checkbox-container input {
  width: 18px;
  height: 18px;
}

/* File info */
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

/* Format help */
.format-help {
  margin-top: 1.5rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 8px;
}

.format-help h6 {
  margin: 0 0 0.75rem;
  color: #495057;
}

.format-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.format-item {
  padding: 0.375rem 0.75rem;
  background: #fff;
  border-radius: 4px;
  font-size: 0.85rem;
  border: 1px solid #dee2e6;
}

.format-item code {
  background: #667eea;
  color: white;
  padding: 0.125rem 0.375rem;
  border-radius: 3px;
  margin-right: 0.5rem;
  font-size: 0.75rem;
}

/* Table */
.table-scroll {
  max-height: 400px;
  overflow-y: auto;
}

.folio-code {
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

/* Buttons */
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

/* Nuevas clases de estilo estandarizado */
.row-hover {
  transition: all 0.2s ease;
}

.row-hover:hover {
  background-color: #f8f9fa;
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.table-row-selected {
  background-color: #e7f3ff !important;
  border-left: 3px solid #667eea;
}

.header-with-badge {
  position: relative;
}

.header-with-badge::after {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  width: 4px;
  height: 100%;
  background: rgba(255, 255, 255, 0.3);
}

.empty-state-icon {
  opacity: 0.95;
  transition: transform 0.2s ease;
}

.empty-state-icon:hover {
  transform: scale(1.05);
}
</style>
