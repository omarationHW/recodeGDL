<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="database" />
      </div>
      <div class="module-view-info">
        <h1>Actualización Públicos</h1>
        <p>Actualización masiva de conceptos de pago</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">JSON de actualización</label>
              <textarea
                class="municipal-form-control"
                rows="12"
                v-model="jsonPayload"
                placeholder='[{"cveconcepto": 1, "descripcion": "...", "ncorto": "...", "cvegrupo": 1}]'
              ></textarea>
              <small class="form-text text-muted">
                Formato: Array de objetos con cveconcepto, descripcion, ncorto y cvegrupo
              </small>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !jsonPayload"
              @click="aplicar"
            >
              <font-awesome-icon icon="check" v-if="!loading" />
              <span v-if="loading">Procesando...</span>
              <span v-else>Aplicar</span>
            </button>

            <button
              class="btn-municipal-secondary"
              @click="limpiar"
              :disabled="loading"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="resultado && resultado.length > 0">
        <div class="municipal-card-header">
          <h5>✅ Resultados de la Actualización</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table" style="width: 100%; border: 1px solid #ddd;">
              <thead class="municipal-table-header" style="background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);">
                <tr>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">ID</th>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">Descripción</th>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">Nombre Corto</th>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">Grupo</th>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">Acción</th>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">Resultado</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(row, idx) in resultado"
                  :key="idx"
                  :class="{
                    'row-success': row.accion === 'ACTUALIZADO' || row.accion === 'INSERTADO',
                    'row-error': row.accion === 'ERROR',
                    'row-hover': true
                  }"
                  style="border-bottom: 1px solid #ddd;"
                >
                  <td style="padding: 8px; border: 1px solid #ddd; font-weight: 600;">
                    {{ row.cveconcepto || '-' }}
                  </td>
                  <td style="padding: 8px; border: 1px solid #ddd;">
                    {{ row.descripcion }}
                  </td>
                  <td style="padding: 8px; border: 1px solid #ddd;">
                    {{ row.ncorto || '-' }}
                  </td>
                  <td style="padding: 8px; border: 1px solid #ddd; text-align: center;">
                    {{ row.cvegrupo || '-' }}
                  </td>
                  <td style="padding: 8px; border: 1px solid #ddd;">
                    <span :class="getBadgeClass(row.accion)">
                      {{ row.accion }}
                    </span>
                  </td>
                  <td style="padding: 8px; border: 1px solid #ddd;">
                    {{ row.resultado }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="summary-info">
            <p><strong>Total procesados:</strong> {{ resultado.length }} registros</p>
          </div>
        </div>
      </div>

      <!-- Mensaje de error -->
      <div class="municipal-card" v-if="error">
        <div class="municipal-card-body">
          <div class="alert alert-danger">
            <strong>Error:</strong> {{ error }}
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'Publicos_Upd'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Actualización Públicos'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'Publicos_Upd'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Actualización Públicos'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const BASE_DB = 'multas_reglamentos'
const OP_UPDATE = 'RECAUDADORA_PUBLICOS_UPD'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const jsonPayload = ref('')
const resultado = ref(null)
const error = ref(null)

function cargarEjemplo(num) {
  switch(num) {
    case 1:
      jsonPayload.value = JSON.stringify([{
        "cveconcepto": 4,
        "descripcion": "PAGO DE DIVERSOS ACTUALIZADO",
        "ncorto": "DIV-ACT",
        "cvegrupo": 1
      }], null, 2)
      break
    case 2:
      jsonPayload.value = JSON.stringify([{
        "cveconcepto": 0,
        "descripcion": "NUEVO CONCEPTO DE PAGO",
        "ncorto": "NUEVO",
        "cvegrupo": 2
      }], null, 2)
      break
    case 3:
      jsonPayload.value = JSON.stringify([
        {"cveconcepto": 1, "descripcion": "IMPUESTO PREDIAL", "ncorto": "PREDIAL", "cvegrupo": 1},
        {"cveconcepto": 2, "descripcion": "TRANSMISION PATRIMONIAL", "ncorto": "TRANSM-PAT", "cvegrupo": 1}
      ], null, 2)
      break
  }
}

async function aplicar() {
  error.value = null
  resultado.value = null

  try {
    // Validar JSON
    let jsonData
    try {
      jsonData = JSON.parse(jsonPayload.value)
    } catch (e) {
      error.value = 'El JSON no es válido: ' + e.message
      return
    }

    showLoading('Consultando...', 'Por favor espere')
    console.log('🔍 Ejecutando SP:', OP_UPDATE)
    console.log('🔍 Datos:', jsonData)

    // Enviar parámetros en el formato que espera GenericController
    const params = [
      {
        nombre: 'p_datos',
        valor: jsonPayload.value,
        tipo: 'string'
      }
    ]

    const data = await execute(OP_UPDATE, BASE_DB, params, '', null, SCHEMA)

    console.log('✅ Resultado:', data)

    // Procesar respuesta
    let arr = []
    if (data && data.result && Array.isArray(data.result)) {
      arr = data.result
    } else if (Array.isArray(data)) {
      arr = data
    } else if (data && data.rows && Array.isArray(data.rows)) {
      arr = data.rows
    }

    resultado.value = arr

  } catch (e) {
    error.value = e.message || 'Error al ejecutar la actualización'
    console.error('❌ Error:', e)
  } finally {
    hideLoading()
  }
}

function limpiar() {
  jsonPayload.value = ''
  resultado.value = null
  error.value = null
}

function getBadgeClass(accion) {
  if (accion === 'ACTUALIZADO') return 'badge badge-warning'
  if (accion === 'INSERTADO') return 'badge badge-success'
  if (accion === 'ERROR') return 'badge badge-danger'
  return 'badge badge-info'
}
</script>

