<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="building" /></div>
      <div class="module-view-info">
        <h1>Empresas</h1>
        <p>Catálogo y consulta de empresas</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Nombre</label>
              <input class="municipal-form-control" v-model="filters.q" @keyup.enter="reload" placeholder="Buscar empresa..." />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload"><font-awesome-icon icon="search" /> Buscar</button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Resultados</h5>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Empresa</th>
                  <th>RFC</th>
                  <th>Contacto</th>
                  <th>Estado</th>
                  <th>Detalle</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="row-hover">
                  <td>{{ r.empresa || r.nombre }}</td>
                  <td><code>{{ r.rfc }}</code></td>
                  <td>{{ r.contacto }}</td>
                  <td>{{ r.estatus }}</td>
                  <td>
                    <button class="btn-municipal-info btn-sm" @click="openDetail(r)"><font-awesome-icon icon="eye" /></button>
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

      <Modal :show="showDetail" title="Detalle de Empresa" @close="showDetail=false" :showDefaultFooter="true">
        <pre class="text-muted" style="white-space: pre-wrap;">{{ JSON.stringify(selected, null, 2) }}</pre>
      </Modal>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import Modal from '@/components/common/Modal.vue'

const BASE_DB = 'multas_reglamentos'
const OP_LIST = 'RECAUDADORA_EMPRESAS' // TODO confirmar

const { loading, execute } = useApi()

const filters = ref({ q: '' })
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const rows = ref([])
const showDetail = ref(false)
const selected = ref(null)

async function reload() {
  const params = [
    { nombre: 'q', tipo: 'string', valor: String(filters.value.q || '') },
    { nombre: 'offset', tipo: 'integer', valor: (page.value - 1) * pageSize.value },
    { nombre: 'limit', tipo: 'integer', valor: pageSize.value }
  ]
  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    // La API puede retornar data.result, data.rows, o data directamente como array
    rows.value = Array.isArray(data?.result) ? data.result
                : Array.isArray(data?.rows) ? data.rows
                : Array.isArray(data) ? data
                : []
    // Si la primera fila tiene total_count, usarlo; sino usar el total del data o el length
    total.value = rows.value.length > 0 && rows.value[0].total_count
      ? Number(rows.value[0].total_count)
      : Number(data?.total ?? data?.count ?? rows.value.length)
  } catch (e) {
    rows.value = []
    total.value = 0
  }
}

function go(p) { page.value = p; reload() }
function openDetail(r) { selected.value = r; showDetail.value = true }

reload()
</script>

