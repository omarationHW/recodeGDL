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
                  <th>Cuenta</th>
                  <th>Folio</th>
                  <th>Año</th>
                  <th>Estatus</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="row-hover">
                  <td><code>{{ r.clave_cuenta }}</code></td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.ejercicio }}</td>
                  <td>{{ r.estatus }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-info btn-sm" @click="openDetail(r)"><font-awesome-icon icon="eye" /></button>
                    </div>
                  </td>
                </tr>
                <tr v-if="rows.length===0"><td colspan="5" class="text-center text-muted">Sin registros</td></tr>
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

      <Modal :show="showDetail" title="Detalle" @close="showDetail=false" :showDefaultFooter="true">
        <pre class="text-muted" style="white-space: pre-wrap;">{{ JSON.stringify(selected, null, 2) }}</pre>
      </Modal>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import Modal from '@/components/common/Modal.vue'

const BASE_DB = 'INFORMIX' // TODO confirmar
const OP_LIST = 'RECAUDADORA_BLOQUEO_MULTA' // TODO confirmar

const { loading, execute } = useApi()

const filters = ref({ cuenta: '', ejercicio: new Date().getFullYear() })
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const rows = ref([])

const showDetail = ref(false)
const selected = ref(null)

async function reload() {
  const params = [
    { name: 'clave_cuenta', type: 'C', value: String(filters.value.cuenta || '') },
    { name: 'ejercicio', type: 'I', value: Number(filters.value.ejercicio || 0) },
    { name: 'offset', type: 'I', value: (page.value - 1) * pageSize.value },
    { name: 'limit', type: 'I', value: pageSize.value }
  ]
  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    rows.value = Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
    total.value = Number(data?.total ?? rows.value.length)
  } catch (e) {
    rows.value = []
    total.value = 0
  }
}

function go(p) { page.value = p; reload() }
function openDetail(r) { selected.value = r; showDetail.value = true }

reload()
</script>

