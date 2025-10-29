<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="exchange-alt" /></div>
      <div class="module-view-info">
        <h1>Requerimientos de Tránsito</h1>
        <p>CRUD real contra BD</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" :disabled="loading" @click="openCreate()">
          <font-awesome-icon icon="plus" /> Nuevo
        </button>
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
                      <button class="btn-municipal-info btn-sm" @click="edit(r)"><font-awesome-icon icon="edit" /></button>
                      <button class="btn-municipal-danger btn-sm" @click="remove(r)"><font-awesome-icon icon="trash" /></button>
                    </div>
                  </td>
                </tr>
                <tr v-if="rows.length===0"><td colspan="5" class="text-center text-muted">Sin registros</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <Modal :show="showModal" :title="modalTitle" @close="closeModal" :showDefaultFooter="true" @confirm="save">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Cuenta</label>
            <input class="municipal-form-control" v-model="form.clave_cuenta" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Folio</label>
            <input class="municipal-form-control" v-model.number="form.folio" type="number" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Año</label>
            <input class="municipal-form-control" v-model.number="form.ejercicio" type="number" />
          </div>
          <div class="form-group full-width">
            <label class="municipal-form-label">Estatus</label>
            <input class="municipal-form-control" v-model="form.estatus" />
          </div>
        </div>
      </Modal>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import Modal from '@/components/common/Modal.vue'

const BASE_DB = 'INFORMIX' // TODO confirmar
const OP_LIST = 'RECAUDADORA_REQTRANS_LIST' // TODO confirmar
const OP_CREATE = 'RECAUDADORA_REQTRANS_CREATE' // TODO confirmar
const OP_UPDATE = 'RECAUDADORA_REQTRANS_UPDATE' // TODO confirmar
const OP_DELETE = 'RECAUDADORA_REQTRANS_DELETE' // TODO confirmar

const { loading, execute } = useApi()

const filters = ref({ cuenta: '', ejercicio: new Date().getFullYear() })
const rows = ref([])

const showModal = ref(false)
const modalTitle = ref('Nuevo registro')
const form = ref({ clave_cuenta: '', folio: null, ejercicio: new Date().getFullYear(), estatus: '' })
let editing = false

async function reload() {
  const params = [
    { name: 'clave_cuenta', type: 'C', value: String(filters.value.cuenta || '') },
    { name: 'ejercicio', type: 'I', value: Number(filters.value.ejercicio || 0) }
  ]
  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    rows.value = Array.isArray(data) ? data : []
  } catch (e) { rows.value = [] }
}

function openCreate() {
  editing = false
  modalTitle.value = 'Nuevo registro'
  form.value = { clave_cuenta: '', folio: null, ejercicio: new Date().getFullYear(), estatus: '' }
  showModal.value = true
}

function edit(r) {
  editing = true
  modalTitle.value = `Editar registro: ${r.clave_cuenta}`
  form.value = { ...r }
  showModal.value = true
}

function closeModal() { showModal.value = false }

async function save() {
  const params = [
    { name: 'registro', type: 'C', value: JSON.stringify(form.value) }
  ]
  try {
    await execute(editing ? OP_UPDATE : OP_CREATE, BASE_DB, params)
    showModal.value = false
    await reload()
  } catch (e) {}
}

async function remove(r) {
  const params = [ { name: 'registro', type: 'C', value: JSON.stringify(r) } ]
  try {
    await execute(OP_DELETE, BASE_DB, params)
    await reload()
  } catch (e) {}
}

reload()
</script>
