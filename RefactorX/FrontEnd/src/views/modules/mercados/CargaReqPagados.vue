<template>
  <div class="container-fluid">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Carga de Requerimientos Pagados
    </div>
    <h1 class="mb-4">Carga de Pagos Realizados en Mdo. Libertad</h1>

    <div class="panel panel-default mb-3 p-3">
      <label for="file" class="form-label">Seleccionar archivo de pagos (TXT):</label>
      <input type="file" id="file" ref="fileInput" class="form-control d-inline-block" style="width: auto;" @change="onFileChange" accept=".txt" />
      <button class="btn btn-primary ml-2" @click="parseFile" :disabled="!file">Cargar Archivo</button>
    </div>

    <div v-if="rows.length > 0">
      <div class="table-responsive" style="max-height: 350px; overflow:auto;">
        <table class="table table-bordered table-sm table-striped">
          <thead class="thead-light">
            <tr>
              <th>Pagos</th><th>Id Local</th><th>Fecha Pago</th><th>Oficina</th><th>Caja</th>
              <th>Operacion</th><th>Folio</th><th>Fecha Actualizacion</th><th>Usuario</th>
              <th>Imp. Multa</th><th>Imp. Gastos</th><th>Folios Requerimientos</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in rows" :key="idx">
              <td>{{ row.pagos }}</td><td>{{ row.id_local }}</td><td>{{ row.fecha_pago }}</td>
              <td>{{ row.oficina }}</td><td>{{ row.caja }}</td><td>{{ row.operacion }}</td>
              <td>{{ row.folio }}</td><td>{{ row.fecha_actualizacion }}</td><td>{{ row.usuario }}</td>
              <td>{{ row.imp_multa }}</td><td>{{ row.imp_gastos }}</td><td>{{ row.folios_requerimientos }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="mt-3">
        <button class="btn btn-success" @click="procesarPagos" :disabled="loading">Actualizar Pagos</button>
        <button class="btn btn-secondary ml-2" @click="reset">Limpiar</button>
      </div>
    </div>

    <div v-if="totales" class="alert alert-info mt-4">
      <div><b>Folios Grabados:</b> {{ totales.grabados }}</div>
      <div><b>Total de Locales:</b> {{ totales.total_pag }}</div>
      <div><b>Total de Multa:</b> ${{ totales.importe_multa }}</div>
      <div><b>Total de Gastos:</b> ${{ totales.importe_gastos }}</div>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
  <DocumentationModal :show="showAyuda" :component-name="'CargaReqPagados'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - CargaReqPagados'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'CargaReqPagados'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - CargaReqPagados'" @close="showDocumentacion = false" />
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)
const BASE_DB = 'mercados'
const SCHEMA = 'publico'

const { loading, execute } = useApi()
const { showToast } = useToast()

const file = ref(null)
const rows = ref([])
const totales = ref(null)
const error = ref('')
const fileInput = ref(null)

const onFileChange = (e) => {
  file.value = e.target.files[0]
  rows.value = []
  totales.value = null
  error.value = ''
}

const parseFile = () => {
  if (!file.value) return
  const reader = new FileReader()
  reader.onload = (e) => {
    const lines = e.target.result.split(/\r?\n/).filter(l => l.trim() !== '')
    rows.value = lines.map((line, idx) => ({
      pagos: idx + 1,
      id_local: line.substr(0, 6).trim(),
      fecha_pago: line.substr(6, 2) + '/' + line.substr(8, 2) + '/' + line.substr(10, 4),
      oficina: line.substr(14, 3).trim(),
      caja: line.substr(17, 1).trim(),
      operacion: line.substr(18, 5).trim(),
      folio: line.substr(23, 6).trim(),
      fecha_actualizacion: line.substr(29, 19).trim(),
      usuario: line.substr(48, 3).trim(),
      imp_multa: line.substr(75, 9).trim(),
      imp_gastos: line.substr(84, 9).trim(),
      folios_requerimientos: line.substr(93, 150).trim()
    }))
    showToast(rows.value.length + ' registros cargados', 'success')
  }
  reader.onerror = () => { error.value = 'Error al leer'; showToast('Error', 'error') }
  reader.readAsText(file.value)
}

const procesarPagos = async () => {
  error.value = ''
  let grabados = 0, errorCount = 0, multa = 0, gastos = 0
  try {
    for (const row of rows.value) {
      const params = [
        { nombre: 'p_id_local', tipo: 'integer', valor: parseInt(row.id_local) || 0 },
        { nombre: 'p_axo', tipo: 'integer', valor: parseInt(row.fecha_pago.split('/')[2]) || 2024 },
        { nombre: 'p_periodo', tipo: 'integer', valor: parseInt(row.fecha_pago.split('/')[1]) || 1 },
        { nombre: 'p_fecha_pago', tipo: 'string', valor: row.fecha_pago },
        { nombre: 'p_oficina_pago', tipo: 'integer', valor: parseInt(row.oficina) || 1 },
        { nombre: 'p_caja_pago', tipo: 'string', valor: row.caja },
        { nombre: 'p_operacion_pago', tipo: 'integer', valor: parseInt(row.operacion) || 0 },
        { nombre: 'p_importe_pago', tipo: 'numeric', valor: (parseFloat(row.imp_multa)||0) + (parseFloat(row.imp_gastos)||0) },
        { nombre: 'p_folio', tipo: 'string', valor: row.folio },
        { nombre: 'p_fecha_actualizacion', tipo: 'string', valor: row.fecha_actualizacion },
        { nombre: 'p_id_usuario', tipo: 'integer', valor: parseInt(row.usuario) || 1 },
        { nombre: 'p_rec', tipo: 'string', valor: '' },
        { nombre: 'p_merc', tipo: 'string', valor: '' },
        { nombre: 'p_id_usuario_sistema', tipo: 'integer', valor: 1 }
      ]
      try {
        await execute('sp_importar_pago_texto', BASE_DB, params, '', null, SCHEMA)
        grabados++
        multa += parseFloat(row.imp_multa) || 0
        gastos += parseFloat(row.imp_gastos) || 0
      } catch (e) { errorCount++ }
    }
    totales.value = { grabados, total_pag: rows.value.length, importe_multa: multa.toFixed(2), importe_gastos: gastos.toFixed(2) }
    showToast(errorCount > 0 ? 'Procesados ' + grabados + ' con ' + errorCount + ' errores' : 'OK: ' + grabados + ' folios', errorCount > 0 ? 'warning' : 'success')
  } catch (e) { error.value = e.message; showToast('Error: ' + e.message, 'error') }
}

const reset = () => {
  file.value = null; rows.value = []; totales.value = null; error.value = ''
  if (fileInput.value) fileInput.value.value = ''
  showToast('Limpiado', 'info')
}
</script>
