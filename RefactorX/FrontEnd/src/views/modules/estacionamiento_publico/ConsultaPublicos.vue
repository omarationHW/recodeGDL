<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="search" /></div>
      <div class="module-view-info">
        <h1>Consulta de Estacionamientos Públicos</h1>
        <p>Listado, filtros y detalles</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" @click="loadData" :disabled="loading">
          <font-awesome-icon icon="sync-alt" /> Actualizar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Categoría</label>
              <input type="text" class="municipal-form-control" v-model="filters.categoria" placeholder="Ej. PB, PC" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Nombre</label>
              <input type="text" class="municipal-form-control" v-model="filters.nombre" placeholder="Nombre del estacionamiento" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Sector</label>
              <input type="text" class="municipal-form-control" v-model="filters.sector" placeholder="J/H/L/R" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="search" :disabled="loading">
              <font-awesome-icon icon="search" /> Buscar
            </button>
            <button class="btn-municipal-secondary" @click="clearFilters" :disabled="loading">
              <font-awesome-icon icon="times" /> Limpiar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" /> Resultados
            <span class="badge-purple" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Categoria</th>
                  <th>Nombre</th>
                  <th>Sector</th>
                  <th>Zona</th>
                  <th>Licencia</th>
                  <th>Cupo</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in items" :key="item.id" class="row-hover">
                  <td>{{ item.categoria }}</td>
                  <td><strong class="text-primary">{{ item.nombre }}</strong></td>
                  <td>{{ item.nomsector }}</td>
                  <td>{{ item.zona }}-{{ item.subzona }}</td>
                  <td><code>{{ item.numlicencia }}</code></td>
                  <td>{{ item.cupo }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-info btn-sm" @click="openDetails(item)">
                        <font-awesome-icon icon="eye" />
                      </button>
                    </div>
                  </td>
                </tr>
                <tr v-if="items.length === 0 && !loading">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Sin resultados</p>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div class="pagination-container" v-if="totalRecords > 0 && !loading">
          <div class="pagination-info">
            Mostrando {{ startIndex }} a {{ endIndex }} de {{ totalRecords }}
          </div>
          <div class="pagination-controls">
            <div class="page-size-selector">
              <label>Mostrar:</label>
              <select v-model.number="itemsPerPage" @change="changePageSize">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
              </select>
            </div>
            <div class="pagination-nav">
              <button class="pagination-button" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1">
                <font-awesome-icon icon="chevron-left" />
              </button>
              <button class="pagination-button" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <Modal :show="showDetails" title="Detalles del Estacionamiento" size="xl" @close="showDetails = false" :showDefaultFooter="false">
      <div v-if="selected">
        <div class="tab-nav">
          <button class="btn-municipal-secondary" :class="{ active: detailTab==='info' }" @click="detailTab='info'">Información</button>
          <button class="btn-municipal-secondary" :class="{ active: detailTab==='adeudos' }" @click="detailTab='adeudos'">Adeudos</button>
          <button class="btn-municipal-secondary" :class="{ active: detailTab==='multas' }" @click="detailTab='multas'">Multas</button>
          <button class="btn-municipal-secondary" :class="{ active: detailTab==='lic' }" @click="detailTab='lic'">Licencia</button>
        </div>
        <div class="details-grid">
          <div v-show="detailTab==='info'" class="detail-section">
            <h6 class="section-title">Información</h6>
            <table class="detail-table">
              <tr><td class="label">Nombre:</td><td>{{ selected.nombre }}</td></tr>
              <tr><td class="label">Licencia:</td><td><code>{{ selected.numlicencia }}</code></td></tr>
              <tr><td class="label">Dirección:</td><td>{{ selected.calle }} {{ selected.numext }}</td></tr>
              <tr><td class="label">Teléfono:</td><td>{{ selected.telefono }}</td></tr>
            </table>
          </div>
          <div v-show="detailTab==='adeudos'" class="detail-section">
            <h6 class="section-title">Adeudos</h6>
            <div v-if="loadingAdeudos" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
            <div class="table-responsive" v-else>
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr><th>Concepto</th><th>Año</th><th>Mes</th><th>Adeudo</th><th>Recargos</th></tr>
                </thead>
                <tbody>
                  <tr v-for="a in adeudos" :key="`${a.concepto}-${a.axo}-${a.mes}`">
                    <td>{{ a.concepto }}</td>
                    <td>{{ a.axo }}</td>
                    <td>{{ a.mes }}</td>
                    <td>{{ formatMoney(a.adeudo) }}</td>
                    <td>{{ formatMoney(a.recargos) }}</td>
                  </tr>
                  <tr v-if="adeudos.length===0"><td colspan="5" class="text-muted text-center">Sin adeudos</td></tr>
                </tbody>
              </table>
            </div>
          </div>
          <div v-show="detailTab==='multas'" class="detail-section">
            <h6 class="section-title">Multas vinculadas</h6>
            <div v-if="loadingFines" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
            <div class="table-responsive" v-else>
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr><th>Acta</th><th>Fecha</th><th>Giro</th><th>Total</th></tr>
                </thead>
                <tbody>
                  <tr v-for="m in multas" :key="m.id_multa">
                    <td>{{ m.num_acta }}</td>
                    <td>{{ formatDate(m.fecha_acta) }}</td>
                    <td>{{ m.giro }}</td>
                    <td>{{ formatMoney(m.total) }}</td>
                  </tr>
                  <tr v-if="multas.length===0"><td colspan="4" class="text-muted text-center">Sin multas</td></tr>
                </tbody>
              </table>
            </div>
          </div>
          <div v-show="detailTab==='lic'" class="detail-section">
            <h6 class="section-title">Licencia General</h6>
            <div class="form-row mb-2">
              <div class="form-group"><label class="municipal-form-label">Reca</label><input type="number" class="municipal-form-control" v-model.number="licReca" /></div>
              <div class="form-group"><label class="municipal-form-label invisible">.</label><button class="btn-municipal-secondary" @click="loadLicGrales" :disabled="loadingLicGrales"><font-awesome-icon icon="sync-alt" /> Cargar</button></div>
            </div>
            <div v-if="loadingLicGrales" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
            <div v-else>
              <table class="detail-table">
                <tr><td class="label">Propietario</td><td>{{ licGrales?.propietario || '—' }}</td></tr>
                <tr><td class="label">Giro</td><td>{{ licGrales?.desc_giro || '—' }}</td></tr>
                <tr><td class="label">Ubicación</td><td>{{ licGrales?.ubicacion || '—' }}</td></tr>
                <tr><td class="label">RFC</td><td>{{ licGrales?.rfc || '—' }}</td></tr>
                <tr><td class="label">Vigente</td><td>{{ licGrales?.vigente || '—' }}</td></tr>
              </table>
            </div>
          </div>
        </div>
      </div>
    </Modal>
  </div>
  <div v-if="loading && items.length===0" class="loading-overlay"><div class="loading-spinner"><div class="spinner"></div><p>Cargando...</p></div></div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import apiService from '@/services/apiService'
import Modal from '@/components/common/Modal.vue'

const loading = ref(false)
const items = ref([])
const totalRecords = ref(0)
const currentPage = ref(1)
const itemsPerPage = ref(10)
const showDetails = ref(false)
const selected = ref(null)
const multas = ref([])
const loadingFines = ref(false)
const adeudos = ref([])
const loadingAdeudos = ref(false)
const licGrales = ref(null)
const loadingLicGrales = ref(false)
const licReca = ref(4)

const filters = ref({ categoria: '', nombre: '', sector: '' })

const startIndex = computed(() => ((currentPage.value - 1) * itemsPerPage.value) + 1)
const endIndex = computed(() => Math.min(currentPage.value * itemsPerPage.value, totalRecords.value))
const totalPages = computed(() => Math.max(1, Math.ceil(totalRecords.value / itemsPerPage.value)))

async function loadData() {
  loading.value = true
  try {
    const parametros = [
      { nombre: 'categoria', valor: filters.value.categoria, tipo: 'string' },
      { nombre: 'nombre', valor: filters.value.nombre, tipo: 'string' },
      { nombre: 'sector', valor: filters.value.sector, tipo: 'string' }
    ]
    const pagination = { limit: itemsPerPage.value, offset: (currentPage.value - 1) * itemsPerPage.value }
    const resp = await apiService.execute('sp_get_public_parking_list', 'estacionamiento_publico', parametros, '', pagination)
    const result = resp?.data?.result || []
    items.value = result
    // Si el backend devuelve conteo, úsalo; en otro caso, toma largo del result
    totalRecords.value = resp?.data?.count ?? result.length
  } catch (e) {
    console.error(e)
    items.value = []
    totalRecords.value = 0
  } finally {
    loading.value = false
  }
}

function search() {
  currentPage.value = 1
  loadData()
}

function clearFilters() {
  filters.value = { categoria: '', nombre: '', sector: '' }
  search()
}

function changePageSize() {
  currentPage.value = 1
  loadData()
}

function goToPage(p) {
  if (p < 1 || p > totalPages.value) return
  currentPage.value = p
  loadData()
}

function formatDate(d) {
  if (!d) return '—'
  const dt = new Date(d)
  return dt.toLocaleDateString()
}

function formatMoney(n) { try { return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(Number(n||0)) } catch { return n } }

async function openDetails(item) {
  selected.value = item
  showDetails.value = true
  multas.value = []
  loadingFines.value = true
  adeudos.value = []
  loadingAdeudos.value = true
  licGrales.value = null
  loadingLicGrales.value = false
  try {
    const parametros = [ { nombre: 'numlicencia', valor: item.numlicencia, tipo: 'integer' } ]
    const resp = await apiService.execute('sp_get_public_parking_fines', 'estacionamiento_publico', parametros)
    multas.value = resp?.data?.result || []
  } catch (e) {
    console.error(e)
    multas.value = []
  } finally {
    loadingFines.value = false
  }

  try {
    // Delphi: cajero_pub_detalle(3, :pubid, 0, 0)
    const paramsAde = [
      { nombre: 'opc', valor: 3, tipo: 'integer' },
      { nombre: 'pubid', valor: item.id, tipo: 'integer' },
      { nombre: 'p3', valor: 0, tipo: 'integer' },
      { nombre: 'p4', valor: 0, tipo: 'integer' }
    ]
    const respA = await apiService.execute('cajero_pub_detalle', 'estacionamiento_publico', paramsAde)
    adeudos.value = respA?.data?.result || []
  } catch (e) {
    console.error(e)
    adeudos.value = []
  } finally {
    loadingAdeudos.value = false
  }
}

async function loadLicGrales() {
  if (!selected.value) return
  loadingLicGrales.value = true
  try {
    // Delphi: spget_lic_grales(NumLicencia, 0, reca)
    const params = [
      { nombre: 'NumLicencia', valor: selected.value.numlicencia, tipo: 'integer' },
      { nombre: 'cero', valor: 0, tipo: 'integer' },
      { nombre: 'reca', valor: licReca.value, tipo: 'integer' }
    ]
    const resp = await apiService.execute('spget_lic_grales', 'estacionamiento_publico', params)
    const rows = resp?.data?.result || []
    licGrales.value = rows[0] || null
  } catch (e) {
    console.error(e)
    licGrales.value = { error: e.message || 'Error' }
  } finally {
    loadingLicGrales.value = false
  }
}

onMounted(loadData)
watch([itemsPerPage], () => { /* handled by changePageSize */ })
</script>
const detailTab = ref('info')
