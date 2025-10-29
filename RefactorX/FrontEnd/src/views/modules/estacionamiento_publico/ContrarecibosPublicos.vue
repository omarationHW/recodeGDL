<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-invoice" /></div>
      <div class="module-view-info">
        <h1>Contrarecibos</h1>
        <p>Alta/Modificación/Baja y suma por fecha</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="sumar"><font-awesome-icon icon="calculator" /> Sumar por fecha</button>
        <button class="btn-municipal-primary" :disabled="loading" @click="guardar"><font-awesome-icon icon="save" /> Guardar</button>
        <button class="btn-municipal-secondary" :disabled="loading" @click="eliminar"><font-awesome-icon icon="trash" /> Eliminar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Ejercicio</label><input type="number" class="municipal-form-control" v-model.number="form.ejercicio" /></div>
            <div class="form-group"><label class="municipal-form-label">Procedencia</label><input type="number" class="municipal-form-control" v-model.number="form.procedencia" /></div>
            <div class="form-group"><label class="municipal-form-label">Contrarecibo</label><input type="number" class="municipal-form-control" v-model.number="form.crbo" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha</label><input type="date" class="municipal-form-control" v-model="form.feccrbo" /></div>
            <div class="form-group"><label class="municipal-form-label">Importe</label><input type="number" class="municipal-form-control" v-model.number="form.importe" step="0.01" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Concepto</label><input class="municipal-form-control" v-model="form.concepto" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Proveedor</label><input type="number" class="municipal-form-control" v-model.number="form.proveedor" /></div>
            <div class="form-group"><label class="municipal-form-label"># Doctos</label><input type="number" class="municipal-form-control" v-model.number="form.doctos" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Ingreso</label><input type="date" class="municipal-form-control" v-model="form.fecingre" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Venc.</label><input type="date" class="municipal-form-control" v-model="form.fecvenci" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Forma Pago</label><input class="municipal-form-control" v-model="form.formapago" maxlength="1" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Notas</label><input class="municipal-form-control" v-model="form.notas" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Param (1=Alta,2=Mod,3=Baja)</label><input type="number" class="municipal-form-control" v-model.number="form.param" /></div>
          </div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Suma por Fecha Ingreso</h5></div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Fecha</label><input type="date" class="municipal-form-control" v-model="sumFecha" /></div>
          </div>
          <p class="text-muted">Total: <strong>{{ sumTotal }}</strong></p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import apiService from '@/services/apiService'

const form = reactive({ ejercicio: 0, procedencia: 0, crbo: 0, feccrbo: '', diasven: 0, importe: 0, concepto: '', proveedor: 0, doctos: 0, fecingre: '', fecvenci: '', feccodi: '', fecveri: '', fecprog: '', fecaja: '', feccancel: '', cvecheq: '', benef: '', formapago: '', notas: '', param: 1, num_ctrol_cheque: 0, clave_movimiento: '', benef_cheque: '' })
const loading = ref(false)
const message = ref('')
const sumFecha = ref('')
const sumTotal = ref(0)

async function guardar() {
  loading.value = true
  message.value = ''
  try {
    const p = Object.entries(form).map(([k,v]) => ({ nombre: `p_${k}`, valor: v, tipo: typeof v === 'number' ? 'integer' : 'string' }))
    const resp = await apiService.execute('spd_crbo_abc', 'estacionamiento_publico', p)
    message.value = resp?.message || 'Operación enviada'
  } finally { loading.value = false }
}

async function eliminar() {
  form.param = 3
  await guardar()
}

async function sumar() {
  const resp = await apiService.execute('sum_contrarecibos_by_date', 'estacionamiento_publico', [ { nombre: 'p_fecha', valor: sumFecha.value, tipo: 'string' } ])
  const val = resp?.eResponse?.data?.result ?? resp?.data?.result
  sumTotal.value = Array.isArray(val) ? (val[0] || 0) : (val || 0)
}
</script>

