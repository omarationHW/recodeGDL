<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar" />
      </div>
      <div class="module-view-info">
        <h1>Actualiza Fecha de Práctica de Empresas</h1>
        <p>Aplicación de fechas a folios de empresas (vía BD)</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="resetAll">
          <font-awesome-icon icon="sync-alt" />
          Limpiar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Ejecutor</label>
              <select class="municipal-form-control" v-model="filters.ejecutor" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="e in ejecutores" :key="e.cveejecutor" :value="e.cveejecutor">
                  {{ e.empresa }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha de corte</label>
              <input class="municipal-form-control" type="date" v-model="filters.fechaCorte" :disabled="loading" />
            </div>
            <div class="form-group full-width">
              <label class="municipal-form-label">Archivo de folios (.txt)</label>
              <input ref="fileInputRef" class="municipal-form-control" type="file" accept=".txt" @change="onFileChange" :disabled="loading" />
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading || !fileContent" @click="parseFile">
              <font-awesome-icon icon="file-alt" />
              Analizar archivo
            </button>
            <button class="btn-municipal-secondary" :disabled="loading || !filters.fechaCorte || folios.length === 0" @click="actualizaTodos">
              <font-awesome-icon icon="check" />
              Actualizar todos
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="folios.length">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" /> Folios a procesar
            <span class="badge-info">{{ folios.length }} folios</span>
          </h5>
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Clave Cuenta</th>
                  <th>Folio</th>
                  <th>Año</th>
                  <th>Propietario</th>
                  <th>Importe Pagado</th>
                  <th>Notificación</th>
                  <th>Fecha Pago</th>
                  <th>Estado</th>
                  <th>Acción</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(f, idx) in folios" :key="`${f.clave_cuenta}-${f.folio}-${f.anio_folio}-${idx}`" class="row-hover">
                  <td>{{ idx + 1 }}</td>
                  <td><code>{{ f.clave_cuenta }}</code></td>
                  <td>{{ f.folio }}</td>
                  <td>{{ f.anio_folio }}</td>
                  <td>{{ f.propietario }}</td>
                  <td class="text-end">{{ formatCurrency(f.importe_pagado) }}</td>
                  <td>{{ f.notificacion }}</td>
                  <td>{{ f.fecha_pago }}</td>
                  <td>
                    <span class="badge" :class="f.estado === 'ACTUALIZADO' ? 'badge-success' : 'badge-secondary'">
                      {{ f.estado || 'PENDIENTE' }}
                    </span>
                  </td>
                  <td>
                    <button class="btn-municipal-primary btn-sm" :disabled="loading || !filters.fechaCorte" @click="actualizaFolio(idx)">
                      <font-awesome-icon icon="save" />
                    </button>
                  </td>
                </tr>
                <tr v-if="folios.length === 0">
                  <td colspan="10" class="text-center text-muted">Sin folios</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="summary mt-2">
            <span class="badge-secondary">Procesados: {{ foliosProcesados }}</span>
            <span class="badge-success">Correctos: {{ foliosCorrectos }}</span>
            <span class="badge-danger">Incorrectos: {{ foliosIncorrectos }}</span>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="errores.length">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="exclamation-triangle" /> Errores
          </h5>
        </div>
        <div class="municipal-card-body">
          <ul class="list-unstyled">
            <li v-for="(err, i) in errores" :key="i">
              <small>
                Folio <strong>{{ err.folio }}</strong> - Cuenta <code>{{ err.clave_cuenta }}</code> - Año {{ err.anio_folio }}: {{ err.error }}
              </small>
            </li>
          </ul>
        </div>
      </div>
    </div>

    <div v-if="loading && folios.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando operación...</p>
      </div>
    </div>
  </div>
  </template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'

// Configuración (ajustar según tu backend genérico)
const BASE_DB = 'multas_reglamentos' // TODO: confirmar alias de base
const OP_GET_EJECUTORES = 'RECAUDADORA_GET_EJECUTORES' // TODO: confirmar nombre
const OP_PARSE_FILE = 'RECAUDADORA_PARSE_FILE' // TODO: confirmar nombre
const OP_APLICA_FECHAS = 'RECAUDADORA_ACTUALIZA_FECHAS' // TODO: confirmar nombre

const { loading, execute } = useApi()

const filters = ref({
  ejecutor: '',
  fechaCorte: ''
})
const ejecutores = ref([])
const fileContent = ref('')
const folios = ref([])
const errores = ref([])
const foliosCorrectos = ref(0)
const foliosIncorrectos = ref(0)
const foliosProcesados = ref(0)
const fileInputRef = ref(null) // Referencia al input file

onMounted(async () => {
  await fetchEjecutores()
})

async function fetchEjecutores() {
  // Debe traer datos reales desde BD vía SP
  try {
    console.log('🔍 Cargando ejecutores...')
    const data = await execute(OP_GET_EJECUTORES, BASE_DB, [])
    console.log('📦 Respuesta ejecutores:', data)

    // La respuesta viene en data.result debido a la estructura del GenericController
    if (data && Array.isArray(data.result)) {
      ejecutores.value = data.result
      console.log('✅ Ejecutores cargados:', ejecutores.value.length)
    } else if (Array.isArray(data)) {
      ejecutores.value = data
      console.log('✅ Ejecutores cargados (array directo):', ejecutores.value.length)
    } else {
      ejecutores.value = []
      console.warn('⚠️ No se encontraron ejecutores')
    }

    if (ejecutores.value.length === 0) {
      console.warn('⚠️ El SP no devolvió ejecutores. Verifica que el SP recaudadora_get_ejecutores esté desplegado correctamente.')
    }
  } catch (e) {
    console.error('❌ Error al cargar ejecutores:', e)
    ejecutores.value = []
    // Mostrar error al usuario
    alert('Error al cargar ejecutores: ' + (e.message || 'Error desconocido') + '\n\nVerifique que el SP recaudadora_get_ejecutores esté desplegado en la base de datos.')
  }
}

function onFileChange(e) {
  const file = e.target.files?.[0]
  if (!file) return
  const reader = new FileReader()
  reader.onload = evt => {
    fileContent.value = String(evt.target?.result || '')
  }
  reader.readAsText(file)
}

async function parseFile() {
  if (!fileContent.value) return
  try {
    const payload = [{ nombre: 'p_file_content', tipo: 'string', valor: fileContent.value }]
    const data = await execute(OP_PARSE_FILE, BASE_DB, payload)
    // La respuesta viene en data.result debido a la estructura del GenericController
    folios.value = Array.isArray(data?.result) ? data.result : (Array.isArray(data?.folios) ? data.folios : (Array.isArray(data) ? data : []))
    foliosProcesados.value = 0
    foliosCorrectos.value = 0
    foliosIncorrectos.value = 0
    errores.value = []
  } catch (e) {}
}

async function actualizaFolio(idx) {
  const f = folios.value[idx]
  if (!f || !filters.value.fechaCorte) return
  try {
    const params = [
      { nombre: 'p_clave_cuenta', tipo: 'string', valor: f.clave_cuenta },
      { nombre: 'p_folio', tipo: 'integer', valor: f.folio },
      { nombre: 'p_anio_folio', tipo: 'integer', valor: f.anio_folio },
      { nombre: 'p_fecha_practica', tipo: 'string', valor: filters.value.fechaCorte },
      { nombre: 'p_ejecutor', tipo: 'integer', valor: filters.value.ejecutor }
    ]
    const data = await execute(OP_APLICA_FECHAS, BASE_DB, params)
    applyResult(data, [f])
  } catch (e) {
    registerErrorFromException(e, f)
  }
}

async function actualizaTodos() {
  if (!filters.value.fechaCorte || folios.value.length === 0) return
  try {
    // Enviar arreglo de folios al SP; estructura genérica por parámetros nombrados
    const params = [
      { nombre: 'p_fecha_practica', tipo: 'string', valor: filters.value.fechaCorte },
      { nombre: 'p_ejecutor', tipo: 'integer', valor: filters.value.ejecutor },
      { nombre: 'p_folios_json', tipo: 'string', valor: JSON.stringify(folios.value.map(f => ({
        clave_cuenta: f.clave_cuenta,
        folio: f.folio,
        anio_folio: f.anio_folio
      }))) }
    ]
    const data = await execute(OP_APLICA_FECHAS, BASE_DB, params)
    applyResult(data, folios.value)
  } catch (e) {
    // error global
  }
}

function applyResult(result, targetFolios) {
  foliosProcesados.value += targetFolios.length
  const erroresSrv = Array.isArray(result?.errores) ? result.errores : []
  const aplicados = Number(result?.aplicados ?? 0)
  foliosCorrectos.value += aplicados
  foliosIncorrectos.value += Math.max(targetFolios.length - aplicados, 0)
  if (erroresSrv.length) {
    errores.value.push(...erroresSrv)
  }
  // marcar estados
  targetFolios.forEach(f => {
    const err = erroresSrv.find(e => e.folio == f.folio && e.clave_cuenta == f.clave_cuenta)
    f.estado = err ? 'PENDIENTE' : 'ACTUALIZADO'
  })
}

function registerErrorFromException(e, f) {
  foliosProcesados.value += 1
  foliosIncorrectos.value += 1
  errores.value.push({
    folio: f?.folio,
    clave_cuenta: f?.clave_cuenta,
    anio_folio: f?.anio_folio,
    error: e?.message || 'Error'
  })
}

function resetAll() {
  filters.value = { ejecutor: '', fechaCorte: '' }
  fileContent.value = ''
  folios.value = []
  errores.value = []
  foliosCorrectos.value = 0
  foliosIncorrectos.value = 0
  foliosProcesados.value = 0
  // Limpiar el input file
  if (fileInputRef.value) {
    fileInputRef.value.value = ''
  }
}

function formatCurrency(v) {
  const n = Number(v || 0)
  return n.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' })
}
</script>

