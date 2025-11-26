<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="ban" /></div>
      <div class="module-view-info">
        <h1>Bloqueo de Multa</h1>
        <p>Administración de bloqueos a folios</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input class="municipal-form-control" v-model="filters.cuenta" @keyup.enter="reload" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input class="municipal-form-control" type="number" v-model.number="filters.ejercicio" @keyup.enter="reload" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload"><font-awesome-icon icon="search" /> Buscar</button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Registros</h5>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Multa</th>
                  <th>Año</th>
                  <th>Monto</th>
                  <th>Total</th>
                  <th>Estatus</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="`row-${r.cvereq}-${idx}`" class="row-hover">
                  <td><code>{{ r.folio || 'N/A' }}</code></td>
                  <td>{{ r.ejercicio || 'N/A' }}</td>
                  <td>${{ formatNumber(r.multas) }}</td>
                  <td>${{ formatNumber(r.total) }}</td>
                  <td>
                    <span v-if="r.bloqueado" class="badge badge-danger">
                      <font-awesome-icon icon="lock" /> {{ r.estatus || 'Bloqueado' }}
                    </span>
                    <span v-else class="badge badge-success">
                      <font-awesome-icon icon="check" /> {{ r.estatus || 'Vigente' }}
                    </span>
                  </td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-info btn-sm" @click="openDetail(r)" title="Ver detalle">
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button v-if="!r.bloqueado" class="btn-municipal-warning btn-sm" @click="openBloquear(r)" title="Bloquear multa">
                        <font-awesome-icon icon="lock" />
                      </button>
                      <button v-else class="btn-municipal-success btn-sm" @click="openDesbloquear(r)" title="Desbloquear multa">
                        <font-awesome-icon icon="unlock" />
                      </button>
                    </div>
                  </td>
                </tr>
                <tr v-if="!loading && rows.length===0"><td colspan="6" class="text-center text-muted">Sin registros</td></tr>
                <tr v-if="loading"><td colspan="6" class="text-center text-muted">Cargando...</td></tr>
              </tbody>
            </table>
          </div>
        </div>

        <div class="pagination-container" v-if="!loading && total > 0">
          <div class="pagination-info">Mostrando {{ (page-1)*pageSize + 1 }} a {{ Math.min(page*pageSize, total) }} de {{ total }}</div>
          <div class="pagination-controls">
            <div class="page-size-selector">
              <label>Mostrar:</label>
              <select v-model.number="pageSize" @change="reload"><option :value="10">10</option><option :value="25">25</option><option :value="50">50</option></select>
            </div>
            <div class="pagination-nav">
              <button class="pagination-button" :disabled="page===1" @click="go(page-1)"><font-awesome-icon icon="chevron-left" /></button>
              <button class="pagination-button" :disabled="page*pageSize>=total" @click="go(page+1)"><font-awesome-icon icon="chevron-right" /></button>
            </div>
          </div>
        </div>
      </div>

      <!-- Modal Detalle -->
      <Modal :show="showDetail" title="Detalle de Multa" @close="showDetail=false" :showDefaultFooter="false">
        <div v-if="selected" class="detail-grid">
          <div class="detail-item"><strong>Folio:</strong> {{ selected.folio }}/{{ selected.ejercicio }}</div>
          <div class="detail-item"><strong>ID Multa:</strong> {{ selected.id_multa }}</div>
          <div class="detail-item"><strong>Fecha Emisión:</strong> {{ selected.fecha_emision }}</div>
          <div class="detail-item"><strong>Multa:</strong> ${{ formatNumber(selected.multas) }}</div>
          <div class="detail-item"><strong>Gastos:</strong> ${{ formatNumber(selected.gastos) }}</div>
          <div class="detail-item"><strong>Total:</strong> ${{ formatNumber(selected.total) }}</div>
          <div class="detail-item"><strong>Estatus:</strong> {{ selected.estatus }}</div>
          <div class="detail-item" v-if="selected.observaciones">
            <strong>Observaciones:</strong><br />
            <span class="text-muted">{{ selected.observaciones }}</span>
          </div>
        </div>
        <template #footer>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="showDetail=false">Aceptar</button>
          </div>
        </template>
      </Modal>

      <!-- Modal Bloquear -->
      <Modal :show="showBloquear" title="Bloquear Multa" @close="showBloquear=false" :showDefaultFooter="false">
        <div v-if="selectedForAction" class="modal-form">
          <div class="form-group">
            <label class="municipal-form-label">Folio:</label>
            <p><strong>{{ selectedForAction.folio }}/{{ selectedForAction.ejercicio }}</strong></p>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Motivo del Bloqueo <span class="text-danger">*</span></label>
            <textarea class="municipal-form-control" v-model="motivoBloqueo" rows="3" placeholder="Ingrese el motivo del bloqueo..." required></textarea>
          </div>
          <div class="button-group">
            <button class="btn-municipal-secondary" @click="showBloquear=false">Cancelar</button>
            <button class="btn-municipal-warning" :disabled="!motivoBloqueo || loadingAction" @click="bloquearMulta">
              <font-awesome-icon v-if="loadingAction" icon="spinner" spin />
              <font-awesome-icon v-else icon="lock" />
              Bloquear
            </button>
          </div>
        </div>
      </Modal>

      <!-- Modal Desbloquear -->
      <Modal :show="showDesbloquear" title="Desbloquear Multa" @close="showDesbloquear=false" :showDefaultFooter="false">
        <div v-if="selectedForAction" class="modal-form">
          <div class="form-group">
            <label class="municipal-form-label">Folio:</label>
            <p><strong>{{ selectedForAction.folio }}/{{ selectedForAction.ejercicio }}</strong></p>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Motivo del Desbloqueo <span class="text-danger">*</span></label>
            <textarea class="municipal-form-control" v-model="motivoDesbloqueo" rows="3" placeholder="Ingrese el motivo del desbloqueo..." required></textarea>
          </div>
          <div class="button-group">
            <button class="btn-municipal-secondary" @click="showDesbloquear=false">Cancelar</button>
            <button class="btn-municipal-success" :disabled="!motivoDesbloqueo || loadingAction" @click="desbloquearMulta">
              <font-awesome-icon v-if="loadingAction" icon="spinner" spin />
              <font-awesome-icon v-else icon="unlock" />
              Desbloquear
            </button>
          </div>
        </div>
      </Modal>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import Modal from '@/components/common/Modal.vue'

const BASE_DB = 'multas_reglamentos'
const OP_LIST = 'RECAUDADORA_BLOQUEO_MULTA'
const OP_BLOQUEAR = 'RECAUDADORA_BLOQUEAR_MULTA'
const OP_DESBLOQUEAR = 'RECAUDADORA_DESBLOQUEAR_MULTA'

const { loading, execute } = useApi()
const { showSuccess, showError } = useToast()

const filters = ref({ cuenta: '', ejercicio: new Date().getFullYear() })
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const rows = ref([])

const showDetail = ref(false)
const selected = ref(null)

const showBloquear = ref(false)
const showDesbloquear = ref(false)
const selectedForAction = ref(null)
const motivoBloqueo = ref('')
const motivoDesbloqueo = ref('')
const loadingAction = ref(false)

async function reload() {
  // Limpiar tabla antes de buscar
  rows.value = []
  total.value = 0

  const params = [
    { nombre: 'p_clave_cuenta', valor: filters.value.cuenta ? String(filters.value.cuenta).trim() : '', tipo: 'string' },
    { nombre: 'p_ejercicio', valor: Number(filters.value.ejercicio || 0), tipo: 'int' },
    { nombre: 'p_offset', valor: (page.value - 1) * pageSize.value, tipo: 'int' },
    { nombre: 'p_limit', valor: pageSize.value, tipo: 'int' }
  ]

  try {
    console.log('🔍 Buscando multas con parámetros:', params)
    console.log('🔍 Cuenta vacía?', !filters.value.cuenta, 'Año:', filters.value.ejercicio)

    const data = await execute(OP_LIST, BASE_DB, params)

    console.log('📦 Respuesta recibida:', data)
    console.log('📊 Tipo de data:', typeof data, Array.isArray(data) ? '(es array)' : '(es objeto)')
    console.log('📊 data.result existe?', data?.result !== undefined)
    console.log('📊 data.result es array?', Array.isArray(data?.result))
    console.log('📊 data.result length:', data?.result?.length)
    console.log('📊 data.count:', data?.count)

    // Validar y limpiar datos antes de asignar
    let resultArray = []

    if (data && typeof data === 'object') {
      if (Array.isArray(data.result)) {
        resultArray = data.result
        console.log('✅ Usando data.result')
      } else if (Array.isArray(data)) {
        resultArray = data
        console.log('✅ Usando data directo')
      }
    }

    // Validar que cada registro tenga los campos necesarios
    const validRecords = resultArray.map((record, idx) => {
      const validated = {
        cvereq: record.cvereq ?? 0,
        clave_cuenta: record.clave_cuenta ?? '',
        folio: record.folio ?? 0,
        ejercicio: record.ejercicio ?? 0,
        estatus: record.estatus ?? 'Desconocido',
        bloqueado: record.bloqueado === true || record.bloqueado === 't',
        id_multa: record.id_multa ?? 0,
        fecha_emision: record.fecha_emision ?? '',
        multas: Number(record.multas ?? 0),
        gastos: Number(record.gastos ?? 0),
        total: Number(record.total ?? 0),
        vigencia: record.vigencia ?? '',
        recaud: record.recaud ?? 0,
        observaciones: record.observaciones ?? ''
      }

      if (idx < 3) {
        console.log(`📝 Registro ${idx}:`, validated)
      }

      return validated
    })

    console.log('✅ Registros validados:', validRecords.length)

    // Asignar de forma reactiva - forzar actualización
    rows.value = [...validRecords]
    total.value = Number(data?.count ?? validRecords.length)

    // Forzar re-render con nextTick
    await new Promise(resolve => setTimeout(resolve, 0))

    console.log('✅ Datos asignados a rows.value:', rows.value.length, 'registros')
    console.log('✅ Total asignado:', total.value)
    console.log('✅ rows.value[0]:', rows.value[0])

    if (validRecords.length === 0) {
      console.log('ℹ️ No se encontraron registros para los criterios de búsqueda')
    } else {
      console.log('🎉 Tabla debería mostrar', validRecords.length, 'registros ahora')
    }
  } catch (e) {
    console.error('❌ Error al cargar registros:', e)
    console.error('❌ Stack:', e.stack)
    rows.value = []
    total.value = 0
    showError('Error al cargar registros: ' + (e.message || 'Error desconocido'))
  }
}

function go(p) {
  page.value = p
  reload()
}

function openDetail(r) {
  selected.value = r
  showDetail.value = true
}

function openBloquear(r) {
  selectedForAction.value = r
  motivoBloqueo.value = ''
  showBloquear.value = true
}

function openDesbloquear(r) {
  selectedForAction.value = r
  motivoDesbloqueo.value = ''
  showDesbloquear.value = true
}

async function bloquearMulta() {
  if (!motivoBloqueo.value || !motivoBloqueo.value.trim()) {
    showError('Debe ingresar el motivo del bloqueo')
    return
  }

  const params = [
    { nombre: 'p_cvereq', valor: Number(selectedForAction.value.cvereq), tipo: 'int' },
    { nombre: 'p_motivo', valor: String(motivoBloqueo.value), tipo: 'string' },
    { nombre: 'p_capturista', valor: 'usuario', tipo: 'string' } // TODO: obtener usuario actual
  ]

  try {
    loadingAction.value = true
    console.log('🔒 Bloqueando multa:', selectedForAction.value.cvereq)

    const data = await execute(OP_BLOQUEAR, BASE_DB, params)
    console.log('📦 Respuesta bloqueo:', data)

    const result = Array.isArray(data?.result) ? data.result[0] : data
    console.log('📊 Resultado procesado:', result)

    if (result?.success === true || result?.success === 't' || result?.success === 'true') {
      console.log('✅ Bloqueo exitoso')
      showSuccess('Multa bloqueada exitosamente')

      // Cerrar modal
      showBloquear.value = false

      // Limpiar estado
      motivoBloqueo.value = ''
      selectedForAction.value = null

      // Recargar tabla para mostrar cambios
      console.log('🔄 Recargando tabla...')
      await reload()
      console.log('✅ Tabla recargada')
    } else {
      console.error('❌ Bloqueo falló:', result?.message)
      showError(result?.message || 'Error al bloquear multa')
    }
  } catch (e) {
    console.error('❌ Error al bloquear:', e)
    showError('Error al bloquear multa: ' + (e.message || 'Error desconocido'))
  } finally {
    loadingAction.value = false
  }
}

async function desbloquearMulta() {
  if (!motivoDesbloqueo.value || !motivoDesbloqueo.value.trim()) {
    showError('Debe ingresar el motivo del desbloqueo')
    return
  }

  const params = [
    { nombre: 'p_cvereq', valor: Number(selectedForAction.value.cvereq), tipo: 'int' },
    { nombre: 'p_motivo', valor: String(motivoDesbloqueo.value), tipo: 'string' },
    { nombre: 'p_capturista', valor: 'usuario', tipo: 'string' } // TODO: obtener usuario actual
  ]

  try {
    loadingAction.value = true
    console.log('🔓 Desbloqueando multa:', selectedForAction.value.cvereq)

    const data = await execute(OP_DESBLOQUEAR, BASE_DB, params)
    console.log('📦 Respuesta desbloqueo:', data)

    const result = Array.isArray(data?.result) ? data.result[0] : data
    console.log('📊 Resultado procesado:', result)

    if (result?.success === true || result?.success === 't' || result?.success === 'true') {
      console.log('✅ Desbloqueo exitoso')
      showSuccess('Multa desbloqueada exitosamente')

      // Cerrar modal
      showDesbloquear.value = false

      // Limpiar estado
      motivoDesbloqueo.value = ''
      selectedForAction.value = null

      // Recargar tabla para mostrar cambios
      console.log('🔄 Recargando tabla...')
      await reload()
      console.log('✅ Tabla recargada')
    } else {
      console.error('❌ Desbloqueo falló:', result?.message)
      showError(result?.message || 'Error al desbloquear multa')
    }
  } catch (e) {
    console.error('❌ Error al desbloquear:', e)
    showError('Error al desbloquear multa: ' + (e.message || 'Error desconocido'))
  } finally {
    loadingAction.value = false
  }
}

function formatNumber(value) {
  if (value == null || value === undefined || value === '') return '0.00'
  const num = Number(value)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

reload()
</script>

<style scoped>
.detail-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1rem;
}

.detail-item {
  padding: 0.5rem;
  border-bottom: 1px solid #eee;
}

.detail-item:last-child {
  border-bottom: none;
}

.modal-form {
  padding: 1rem 0;
}

.modal-form .form-group {
  margin-bottom: 1rem;
}

.badge {
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  font-size: 0.875rem;
  font-weight: 500;
}

.badge-success {
  background-color: #28a745;
  color: white;
}

.badge-danger {
  background-color: #dc3545;
  color: white;
}

.btn-municipal-warning {
  background-color: #ffc107;
  color: #000;
}

.btn-municipal-warning:hover {
  background-color: #e0a800;
}

.text-danger {
  color: #dc3545;
}
</style>

