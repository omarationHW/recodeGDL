<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="folder-open" /></div>
      <div class="module-view-info">
        <h1>Expedientes SVN</h1>
        <p>Gestión de expedientes de cobranza coactiva</p>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Buscar</label>
              <input class="municipal-form-control" v-model="filters.q" @keyup.enter="reload" placeholder="Expediente, cuenta, contribuyente" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input class="municipal-form-control" type="number" v-model.number="filters.year" @keyup.enter="reload" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fase</label>
              <select class="municipal-form-control" v-model="filters.fase" @change="reload">
                <option value="">Todas</option>
                <option value="REQUERIMIENTO">Requerimiento</option>
                <option value="EMBARGO">Embargo</option>
                <option value="REMATE">Remate</option>
                <option value="ADJUDICACION">Adjudicación</option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Expedientes</h5>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Expediente</th>
                  <th>Cuenta</th>
                  <th>Contribuyente</th>
                  <th>Fase</th>
                  <th>Fecha</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="row-hover">
                  <td><strong>{{ r.expediente }}</strong></td>
                  <td><code>{{ r.clave_cuenta }}</code></td>
                  <td>{{ r.contribuyente }}</td>
                  <td>{{ r.fase }}</td>
                  <td>{{ r.fecha }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-info btn-sm" @click="openDetail(r)"><font-awesome-icon icon="eye" /></button>
                    </div>
                  </td>
                </tr>
                <tr v-if="rows.length===0"><td colspan="6" class="text-center text-muted">Sin resultados</td></tr>
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

      <Modal :show="showDetail" title="Detalle de expediente" @close="showDetail=false" :showDefaultFooter="true">
        <pre class="text-muted" style="white-space: pre-wrap;">{{ JSON.stringify(selected, null, 2) }}</pre>
      </Modal>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import Modal from '@/components/common/Modal.vue'

const BASE_DB = 'INFORMIX' // confirmar
const OP_LIST = 'APREMIOSSVN_EXPEDIENTES_LIST'

const { loading, execute } = useApi()

const filters = ref({ q: '', year: new Date().getFullYear(), fase: '' })
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const rows = ref([])
const showDetail = ref(false)
const selected = ref(null)

async function reload() {
  const params = [
    { name: 'q', type: 'C', value: String(filters.value.q || '') },
    { name: 'year', type: 'I', value: Number(filters.value.year || 0) },
    { name: 'fase', type: 'C', value: String(filters.value.fase || '') },
    { name: 'offset', type: 'I', value: (page.value - 1) * pageSize.value },
    { name: 'limit', type: 'I', value: pageSize.value }
  ]
  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    const arr = Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
    rows.value = arr
    total.value = Number(data?.total ?? arr.length)
  } catch (e) {
    rows.value = []
    total.value = 0
  }
}

function go(p) { page.value = p; reload() }
function openDetail(r) { selected.value = r; showDetail.value = true }

reload()
</script>

