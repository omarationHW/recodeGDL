<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="plus" /></div>
      <div class="module-view-info">
        <h1>Transacciones — Estacionamientos Públicos</h1>
        <p>Alta de registros</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" @click="submit" :disabled="submitting">
          <font-awesome-icon icon="save" /> Guardar
        </button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <form @submit.prevent="submit">
            <div class="form-row">
              <div class="form-group"><label class="municipal-form-label">Sector</label><input class="municipal-form-control" v-model="form.cve_sector" /></div>
              <div class="form-group"><label class="municipal-form-label">Categoría</label><input class="municipal-form-control" v-model="form.cve_categ" /></div>
              <div class="form-group"><label class="municipal-form-label">Número</label><input class="municipal-form-control" v-model="form.cve_numero" /></div>
            </div>
            <div class="form-row">
              <div class="form-group full-width"><label class="municipal-form-label">Nombre</label><input class="municipal-form-control" v-model="form.nombre" /></div>
            </div>
            <div class="form-row">
              <div class="form-group"><label class="municipal-form-label">Teléfono</label><input class="municipal-form-control" v-model="form.telefono" /></div>
              <div class="form-group"><label class="municipal-form-label">Calle</label><input class="municipal-form-control" v-model="form.calle" /></div>
              <div class="form-group"><label class="municipal-form-label">Num</label><input class="municipal-form-control" v-model="form.num" /></div>
            </div>
            <div class="form-row">
              <div class="form-group"><label class="municipal-form-label">Cupo</label><input class="municipal-form-control" v-model="form.cupo" /></div>
              <div class="form-group"><label class="municipal-form-label">Fecha alta</label><input type="date" class="municipal-form-control" v-model="form.fecha_alta" /></div>
              <div class="form-group"><label class="municipal-form-label">Fecha inicio</label><input type="date" class="municipal-form-control" v-model="form.fecha_inic" /></div>
            </div>
            <div class="form-row">
              <div class="form-group"><label class="municipal-form-label">Fecha venc.</label><input type="date" class="municipal-form-control" v-model="form.fecha_venci" /></div>
              <div class="form-group"><label class="municipal-form-label">Zona</label><input class="municipal-form-control" v-model="form.zona" /></div>
              <div class="form-group"><label class="municipal-form-label">Subzona</label><input class="municipal-form-control" v-model="form.subzona" /></div>
            </div>
            <div class="form-row">
              <div class="form-group"><label class="municipal-form-label">Num Licencia</label><input class="municipal-form-control" v-model="form.numlic" /></div>
              <div class="form-group"><label class="municipal-form-label">Estatus</label><input class="municipal-form-control" v-model="form.estatus" /></div>
              <div class="form-group"><label class="municipal-form-label">Clave</label><input class="municipal-form-control" v-model="form.clave" /></div>
            </div>
          </form>
          <div v-if="submitting" class="spinner-border" role="status"><span class="visually-hidden">Guardando...</span></div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import apiService from '@/services/apiService'

const submitting = ref(false)
const message = ref('')

const form = reactive({
  cve_sector: '', cve_categ: '', cve_numero: '', nombre: '', telefono: '', calle: '', num: '',
  cupo: '', fecha_alta: '', fecha_inic: '', fecha_venci: '', delas: '', alas: '', delas1: '', alas1: '',
  frec_lunes: '', frec_martes: '', frec_miercoles: '', frec_jueves: '', frec_viernes: '', frec_sabado: '', frec_domingo: '',
  pol_num: '', pol_fec_ven: '', numlic: '', zona: '', subzona: '', estatus: '', clave: '', control: 0
})

async function submit() {
  submitting.value = true
  message.value = ''
  try {
    const parametros = Object.entries(form).map(([nombre, valor]) => ({ nombre, valor, tipo: typeof valor === 'number' ? 'integer' : 'string' }))
    const resp = await apiService.execute('sp_ta_15_publicos_insert', 'estacionamiento_publico', parametros)
    const ok = resp?.success
    message.value = ok ? 'Alta guardada correctamente' : (resp?.message || 'No se pudo guardar')
  } catch (e) {
    message.value = e.message || 'Error en la transacción'
  } finally {
    submitting.value = false
  }
}
</script>

