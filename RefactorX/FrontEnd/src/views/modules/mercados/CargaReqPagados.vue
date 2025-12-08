<template>
  <div class="container-fluid">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Carga de Requerimientos Pagados
    </div>
    <h1 class="mb-4">Carga de Pagos Realizados en Mdo. Libertad</h1>

    <div class="panel panel-default mb-3 p-3">
      <label for="file" class="form-label">Seleccionar archivo de pagos (TXT):</label>
      <input
        type="file"
        id="file"
        ref="fileInput"
        class="form-control d-inline-block"
        style="width: auto;"
        @change="onFileChange"
        accept=".txt"
      />
      <button
        class="btn btn-primary ml-2"
        @click="parseFile"
        :disabled="!file"
      >
        Cargar Archivo
      </button>
    </div>

    <div v-if="rows.length > 0">
      <div class="table-responsive" style="max-height: 350px; overflow:auto;">
        <table class="table table-bordered table-sm table-striped">
          <thead class="thead-light">
            <tr>
              <th>Pagos</th>
              <th>Id Local</th>
              <th>Fecha Pago</th>
              <th>Oficina</th>
              <th>Caja</th>
              <th>Operacion</th>
              <th>Folio</th>
              <th>Fecha Actualizacion</th>
              <th>Usuario</th>
              <th>Imp. Multa</th>
              <th>Imp. Gastos</th>
              <th>Folios Requerimientos</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in rows" :key="idx">
              <td>{{ row.pagos }}</td>
              <td>{{ row.id_local }}</td>
              <td>{{ row.fecha_pago }}</td>
              <td>{{ row.oficina }}</td>
              <td>{{ row.caja }}</td>
              <td>{{ row.operacion }}</td>
              <td>{{ row.folio }}</td>
              <td>{{ row.fecha_actualizacion }}</td>
              <td>{{ row.usuario }}</td>
              <td>{{ row.imp_multa }}</td>
              <td>{{ row.imp_gastos }}</td>
              <td>{{ row.folios_requerimientos }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="mt-3">
        <button
          class="btn btn-success"
          @click="procesarPagos"
          :disabled="globalLoading.isLoading.value"
        >
          Actualizar Pagos
        </button>
        <button
          class="btn btn-secondary ml-2"
          @click="reset"
        >
          Limpiar
        </button>
      </div>
    </div>

    <div v-if="totales" class="alert alert-info mt-4">
      <div><b>Folios Grabados:</b> {{ totales.grabados }}</div>
      <div><b>Total de Locales:</b> {{ totales.total_pag }}</div>
      <div><b>Total de Multa:</b> ${{ totales.importe_multa.toFixed(2) }}</div>
      <div><b>Total de Gastos:</b> ${{ totales.importe_gastos.toFixed(2) }}</div>
    </div>

    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'

// ============================================================================
// COMPOSABLES
// ============================================================================
const globalLoading = useGlobalLoading()
const { showToast } = useToast()

// ============================================================================
// REFS - Estado del componente
// ============================================================================
const file = ref(null)
const rows = ref([])
const totales = ref(null)
const error = ref('')
const fileInput = ref(null)

// ============================================================================
// MÉTODOS - Manejo de archivo
// ============================================================================

/**
 * Maneja el cambio de archivo seleccionado
 * @param {Event} e - Evento de cambio del input file
 */
const onFileChange = (e) => {
  file.value = e.target.files[0]
  rows.value = []
  totales.value = null
  error.value = ''
}

/**
 * Parsea el archivo TXT y extrae los registros de pagos
 * Formato de archivo: posiciones fijas según especificación
 */
const parseFile = () => {
  if (!file.value) return

  const reader = new FileReader()

  reader.onload = (e) => {
    const lines = e.target.result.split(/\r?\n/).filter(l => l.trim() !== '')

    rows.value = lines.map((line, idx) => {
      return {
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
      }
    })

    showToast(`${rows.value.length} registros cargados correctamente`, 'success')
  }

  reader.onerror = () => {
    error.value = 'Error al leer el archivo'
    showToast('Error al leer el archivo', 'error')
  }

  reader.readAsText(file.value)
}

// ============================================================================
// MÉTODOS - Procesamiento de pagos
// ============================================================================

/**
 * Procesa los pagos enviándolos al backend
 * Utiliza globalLoading para mostrar estado de carga
 */
const procesarPagos = async () => {
  error.value = ''

  await globalLoading.withLoading(async () => {
    try {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          eRequest: {
            action: 'processPagos',
            data: {
              registros: rows.value
            }
          }
        })
      })

      const json = await res.json()

      if (json.eResponse.status === 'ok') {
        totales.value = json.eResponse.data
        showToast(
          `Pagos procesados exitosamente. ${totales.value.grabados} folios grabados.`,
          'success'
        )
      } else {
        error.value = (json.eResponse.errors || []).join(', ')
        showToast(error.value || 'Error al procesar pagos', 'error')
      }
    } catch (err) {
      error.value = err.message
      showToast(`Error: ${err.message}`, 'error')
    }
  }, 'Procesando pagos...', 'Por favor espere mientras se actualizan los registros')
}

/**
 * Resetea el formulario a su estado inicial
 */
const reset = () => {
  file.value = null
  rows.value = []
  totales.value = null
  error.value = ''

  if (fileInput.value) {
    fileInput.value.value = ''
  }

  showToast('Formulario limpiado', 'info')
}
</script>
