<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file" /></div>
      <div class="module-view-info">
        <h1>Nuevo Estacionamiento Público</h1>
        <p>Alta guiada</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loadingPredio" @click="consultarPredio"><font-awesome-icon icon="search" /> Consultar Predio</button>
        <button class="btn-municipal-primary" :disabled="creating" @click="create"><font-awesome-icon icon="save" /> Crear</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Categoría (ID)</label><input class="municipal-form-control" type="number" v-model.number="form.pubcategoria_id" /></div>
            <div class="form-group"><label class="municipal-form-label">Número</label><input class="municipal-form-control" type="number" v-model.number="form.numesta" /></div>
            <div class="form-group"><label class="municipal-form-label">Sector</label><input class="municipal-form-control" v-model="form.sector" placeholder="J/H/L/R" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Zona</label><input class="municipal-form-control" type="number" v-model.number="form.zona" /></div>
            <div class="form-group"><label class="municipal-form-label">Subzona</label><input class="municipal-form-control" type="number" v-model.number="form.subzona" /></div>
            <div class="form-group"><label class="municipal-form-label">Num. Licencia</label><input class="municipal-form-control" type="number" v-model.number="form.numlicencia" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Axo Licencias</label><input class="municipal-form-control" type="number" v-model.number="form.axolicencias" /></div>
            <div class="form-group"><label class="municipal-form-label">Clave Cuenta</label><input class="municipal-form-control" type="number" v-model.number="form.cvecuenta" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Nombre</label><input class="municipal-form-control" v-model="form.nombre" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Calle</label><input class="municipal-form-control" v-model="form.calle" /></div>
            <div class="form-group"><label class="municipal-form-label">Num Ext</label><input class="municipal-form-control" v-model="form.numext" /></div>
            <div class="form-group"><label class="municipal-form-label">Teléfono</label><input class="municipal-form-control" v-model="form.telefono" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Cupo</label><input class="municipal-form-control" type="number" v-model.number="form.cupo" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Alta</label><input type="date" class="municipal-form-control" v-model="form.fecha_at" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Inicial</label><input type="date" class="municipal-form-control" v-model="form.fecha_inicial" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Venc.</label><input type="date" class="municipal-form-control" v-model="form.fecha_vencimiento" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">RFC</label><input class="municipal-form-control" v-model="form.rfc" /></div>
            <div class="form-group"><label class="municipal-form-label">Solicitud</label><input class="municipal-form-control" type="number" v-model.number="form.solicitud" /></div>
            <div class="form-group"><label class="municipal-form-label">Control</label><input class="municipal-form-control" type="number" v-model.number="form.control" /></div>
            <div class="form-group"><label class="municipal-form-label">Movtos No</label><input class="municipal-form-control" type="number" v-model.number="form.movtos_no" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Movto Clave</label><input class="municipal-form-control" v-model="form.movto_cve" /></div>
            <div class="form-group"><label class="municipal-form-label">Movto Usuario</label><input class="municipal-form-control" type="number" v-model.number="form.movto_usr" /></div>
          </div>
          <hr />
          <div class="form-row">
            <div class="form-group full-width"><label class="municipal-form-label">Clave Catastral (consulta predio)</label><input class="municipal-form-control" v-model="claveCatastral" placeholder="Clave catastral" /></div>
          </div>
          <div v-if="loadingPredio" class="spinner-border" role="status"><span class="visually-hidden">Consultando predio...</span></div>
          <p v-if="predioMsg" class="text-muted">{{ predioMsg }}</p>
          <div v-if="creating" class="spinner-border" role="status"><span class="visually-hidden">Creando...</span></div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import apiService from '@/services/apiService'

const form = reactive({
  pubcategoria_id: null,
  numesta: null,
  sector: '',
  zona: null,
  subzona: null,
  numlicencia: null,
  axolicencias: null,
  cvecuenta: null,
  nombre: '',
  calle: '',
  numext: '',
  telefono: '',
  cupo: null,
  fecha_at: '',
  fecha_inicial: '',
  fecha_vencimiento: '',
  rfc: '',
  movtos_no: 0,
  movto_cve: 'A',
  movto_usr: 0,
  solicitud: 0,
  control: 0
})
const claveCatastral = ref('')
const loadingPredio = ref(false)
const predioMsg = ref('')
const creating = ref(false)
const message = ref('')

async function consultarPredio() {
  if (!claveCatastral.value) { predioMsg.value = 'Ingrese una clave catastral'; return }
  loadingPredio.value = true
  predioMsg.value = ''
  try {
    const params = [ { nombre: 'opc', valor: 1, tipo: 'integer' }, { nombre: 'dato', valor: claveCatastral.value, tipo: 'string' } ]
    const resp = await apiService.execute('cons_predio', 'estacionamiento_publico', params)
    const r = (resp?.data?.result || [])[0]
    if (r) {
      form.cvecuenta = r.cvecuenta || form.cvecuenta
      form.zona = r.zona || form.zona
      form.subzona = r.subzona || form.subzona
      form.calle = r.calle || form.calle
      form.numext = r.numext || form.numext
      predioMsg.value = `Predio encontrado: ${r.contribuyente || ''}`
    } else {
      predioMsg.value = 'No se encontró predio'
    }
  } catch (e) {
    predioMsg.value = e.message || 'Error consultando predio'
  } finally {
    loadingPredio.value = false
  }
}

async function create() {
  creating.value = true
  message.value = ''
  try {
    const params = [
      { nombre: 'pubcategoria_id', valor: form.pubcategoria_id, tipo: 'integer' },
      { nombre: 'numesta', valor: form.numesta, tipo: 'integer' },
      { nombre: 'sector', valor: form.sector, tipo: 'string' },
      { nombre: 'zona', valor: form.zona, tipo: 'integer' },
      { nombre: 'subzona', valor: form.subzona, tipo: 'integer' },
      { nombre: 'numlicencia', valor: form.numlicencia, tipo: 'integer' },
      { nombre: 'axolicencias', valor: form.axolicencias, tipo: 'integer' },
      { nombre: 'cvecuenta', valor: form.cvecuenta, tipo: 'integer' },
      { nombre: 'nombre', valor: form.nombre, tipo: 'string' },
      { nombre: 'calle', valor: form.calle, tipo: 'string' },
      { nombre: 'numext', valor: form.numext, tipo: 'string' },
      { nombre: 'telefono', valor: form.telefono, tipo: 'string' },
      { nombre: 'cupo', valor: form.cupo, tipo: 'integer' },
      { nombre: 'fecha_at', valor: form.fecha_at, tipo: 'string' },
      { nombre: 'fecha_inicial', valor: form.fecha_inicial, tipo: 'string' },
      { nombre: 'fecha_vencimiento', valor: form.fecha_vencimiento, tipo: 'string' },
      { nombre: 'rfc', valor: form.rfc, tipo: 'string' },
      { nombre: 'movtos_no', valor: form.movtos_no, tipo: 'integer' },
      { nombre: 'movto_cve', valor: form.movto_cve, tipo: 'string' },
      { nombre: 'movto_usr', valor: form.movto_usr, tipo: 'integer' },
      { nombre: 'solicitud', valor: form.solicitud, tipo: 'integer' },
      { nombre: 'control', valor: form.control, tipo: 'integer' }
    ]
    const resp = await apiService.execute('sppubalta', 'estacionamiento_publico', params)
    const r = (resp?.data?.result || [])[0]
    if (r?.result === 1) {
      message.value = `Alta exitosa. ID nuevo: ${r.idnvo}`
    } else {
      message.value = r?.resultstr || 'No se pudo crear'
    }
  } catch (e) {
    message.value = e.message || 'Error en el proceso'
  } finally {
    creating.value = false
  }
}
</script>
