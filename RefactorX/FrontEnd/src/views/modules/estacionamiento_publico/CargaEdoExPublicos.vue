<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-upload" /></div>
      <div class="module-view-info">
        <h1>Carga Estado/Externos</h1>
        <p>Insertar datos, afectar remesa y bitácora</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loadingIns" @click="insertar"><font-awesome-icon icon="plus" /> Insertar</button>
        <button class="btn-municipal-secondary" :disabled="loadingAfect" @click="afectar"><font-awesome-icon icon="bolt" /> Afectar</button>
        <button class="btn-municipal-primary" :disabled="loadingBit" @click="bitacora"><font-awesome-icon icon="bookmark" /> Bitácora</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Mpio</label><input type="number" class="municipal-form-control" v-model.number="mpio" /></div>
            <div class="form-group"><label class="municipal-form-label">Tipo Act</label><input class="municipal-form-control" v-model="tipoact" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio</label><input type="number" class="municipal-form-control" v-model.number="folio" /></div>
            <div class="form-group"><label class="municipal-form-label">Placa</label><input class="municipal-form-control" v-model="placa" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Fec Pago</label><input type="date" class="municipal-form-control" v-model="fecpago" /></div>
            <div class="form-group"><label class="municipal-form-label">Importe</label><input type="number" class="municipal-form-control" v-model.number="importe" step="0.01" /></div>
            <div class="form-group"><label class="municipal-form-label">Fec Alta</label><input type="date" class="municipal-form-control" v-model="fecalta" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Remesa</label><input class="municipal-form-control" v-model="remesa" /></div>
            <div class="form-group"><label class="municipal-form-label">Fec Remesa</label><input type="date" class="municipal-form-control" v-model="fecharemesa" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Bitacora: Inicio</label><input type="date" class="municipal-form-control" v-model="bit_ini" /></div>
            <div class="form-group"><label class="municipal-form-label">Bitacora: Fin</label><input type="date" class="municipal-form-control" v-model="bit_fin" /></div>
            <div class="form-group"><label class="municipal-form-label">Bitacora: Fecha</label><input type="date" class="municipal-form-control" v-model="bit_fecha" /></div>
            <div class="form-group"><label class="municipal-form-label">Bitacora: #Remesa</label><input type="number" class="municipal-form-control" v-model.number="bit_numrem" /></div>
            <div class="form-group"><label class="municipal-form-label">Bitacora: #Reg</label><input type="number" class="municipal-form-control" v-model.number="bit_cantreg" /></div>
          </div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const mpio = ref(0), tipoact = ref(''), folio = ref(0), placa = ref(''), fecpago = ref(''), importe = ref(0), fecalta = ref(''), remesa = ref(''), fecharemesa = ref('')
const bit_ini = ref(''), bit_fin = ref(''), bit_fecha = ref(''), bit_numrem = ref(0), bit_cantreg = ref(0)
const message = ref('')
const loadingIns = ref(false), loadingAfect = ref(false), loadingBit = ref(false)

async function insertar() {
  loadingIns.value = true; message.value = ''
  try {
    const params = [ { nombre: 'vMpio', valor: mpio.value, tipo: 'integer' }, { nombre: 'vTipoAct', valor: tipoact.value, tipo: 'string' }, { nombre: 'vFolio', valor: folio.value, tipo: 'integer' }, { nombre: 'vPlaca', valor: placa.value, tipo: 'string' }, { nombre: 'vFecPago', valor: fecpago.value, tipo: 'string' }, { nombre: 'vImporte', valor: importe.value, tipo: 'numeric' }, { nombre: 'vFecAlta', valor: fecalta.value, tipo: 'string' }, { nombre: 'vRemesa', valor: remesa.value, tipo: 'string' }, { nombre: 'vFecRemesa', valor: fecharemesa.value, tipo: 'string' } ]
    const resp = await apiService.execute('sp_insert_ta14_datos_edo', 'estacionamiento_publico', params)
    message.value = resp?.message || 'Insertado'
  } finally { loadingIns.value = false }
}

async function afectar() {
  loadingAfect.value = true; message.value = ''
  try {
    const resp = await apiService.execute('sp_afec_esta01', 'estacionamiento_publico', [ { nombre: 'p_fecha', valor: bit_fecha.value, tipo: 'string' } ])
    message.value = resp?.message || 'Afectado'
  } finally { loadingAfect.value = false }
}

async function bitacora() {
  loadingBit.value = true; message.value = ''
  try {
    const params = [ { nombre: 'p_fecha_inicio', valor: bit_ini.value, tipo: 'string' }, { nombre: 'p_fecha_fin', valor: bit_fin.value, tipo: 'string' }, { nombre: 'p_fecha', valor: bit_fecha.value, tipo: 'string' }, { nombre: 'p_num_rem', valor: bit_numrem.value, tipo: 'integer' }, { nombre: 'p_cant_reg', valor: bit_cantreg.value, tipo: 'integer' } ]
    const resp = await apiService.execute('sp_insert_ta14_bitacora', 'estacionamiento_publico', params)
    message.value = resp?.message || 'Registrado en bitácora'
  } finally { loadingBit.value = false }
}
</script>

