<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-invoice" /></div>
      <div class="module-view-info">
        <h1>Consulta Requerimientos 400</h1>
        <p>Consulta de requerimientos fiscales del Artículo 400 por cuenta y ejercicio</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                @keyup.enter="filters.cuenta.trim() && reload()"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="filters.ejercicio"
                placeholder="Ej: 2024"
                @keyup.enter="filters.cuenta.trim() && reload()"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.cuenta.trim()"
              @click="reload"
            >
              <font-awesome-icon icon="search" v-if="!loading" />
              <font-awesome-icon icon="spinner" spin v-if="loading" />
              {{ loading ? 'Buscando...' : 'Buscar' }}
            </button>
            <button
              class="btn-municipal-secondary"
              :disabled="loading"
              @click="limpiar"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Resultados</h5>
          <div v-if="loading" class="spinner-border" role="status"><span class="visualmente-hidden">Cargando...</span></div>
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
                  <th>Fecha</th>
                  <th>Detalle</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="row-hover">
                  <td><code>{{ r.clave_cuenta }}</code></td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.ejercicio }}</td>
                  <td>{{ r.estatus }}</td>
                  <td>{{ r.fecha }}</td>
                  <td>
                    <button class="btn-municipal-info btn-sm" @click="openDetail(r)">
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="6" class="text-center text-muted">Sin resultados</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div class="pagination-container" v-if="!loading && total > 0">
          <div class="pagination-info">
            Mostrando {{ (page-1)*pageSize + 1 }} a {{ Math.min(page*pageSize, total) }} de {{ total }}
          </div>
          <div class="pagination-controls">
            <div class="page-size-selector">
              <label>Mostrar:</label>
              <select v-model.number="pageSize" @change="reload">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
              </select>
            </div>
            <div class="pagination-nav">
              <button class="pagination-button" :disabled="page===1" @click="go(page-1)">
                <font-awesome-icon icon="chevron-left" />
              </button>
              <button class="pagination-button" :disabled="page*pageSize>=total" @click="go(page+1)">
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <Modal :show="showDetail" title="Detalle del Requerimiento" @close="showDetail=false" :showDefaultFooter="false">
        <div v-if="selected" class="detail-content">
          <div class="detail-section">
            <h6 class="detail-section-title">Información General</h6>
            <div class="detail-grid">
              <div class="detail-item">
                <label class="detail-label">Cuenta:</label>
                <span class="detail-value">{{ selected.clave_cuenta }}</span>
              </div>
              <div class="detail-item">
                <label class="detail-label">Folio:</label>
                <span class="detail-value">{{ selected.folio }}</span>
              </div>
              <div class="detail-item">
                <label class="detail-label">Ejercicio:</label>
                <span class="detail-value">{{ selected.ejercicio }}</span>
              </div>
              <div class="detail-item">
                <label class="detail-label">Estatus:</label>
                <span class="detail-value" :class="'badge-' + selected.estatus.toLowerCase()">{{ selected.estatus }}</span>
              </div>
            </div>
          </div>

          <div class="detail-section">
            <h6 class="detail-section-title">Fechas y Horarios</h6>
            <div class="detail-grid">
              <div class="detail-item">
                <label class="detail-label">Fecha Requerimiento:</label>
                <span class="detail-value">{{ selected.fecha }}</span>
              </div>
              <div class="detail-item">
                <label class="detail-label">Fecha Entrada 1:</label>
                <span class="detail-value">{{ selected.fecent1 || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <label class="detail-label">Fecha Entrada 2:</label>
                <span class="detail-value">{{ selected.fecent2 || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <label class="detail-label">Fecha Práctica:</label>
                <span class="detail-value">{{ selected.fecpra || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <label class="detail-label">Hora Práctica:</label>
                <span class="detail-value">{{ selected.horapra || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <label class="detail-label">Fecha Cita:</label>
                <span class="detail-value">{{ selected.feccita || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <label class="detail-label">Hora Cita:</label>
                <span class="detail-value">{{ selected.horacit || 'N/A' }}</span>
              </div>
            </div>
          </div>

          <div class="detail-section">
            <h6 class="detail-section-title">Información Adicional</h6>
            <div class="detail-grid">
              <div class="detail-item">
                <label class="detail-label">Práctica Req:</label>
                <span class="detail-value">{{ selected.prareq || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <label class="detail-label">Vigencia Req:</label>
                <span class="detail-value">{{ selected.vigreq || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <label class="detail-label">Diligencia Req:</label>
                <span class="detail-value">{{ selected.dilreq || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <label class="detail-label">Acto Req:</label>
                <span class="detail-value">{{ selected.actreq || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <label class="detail-label">Oficina Notarial:</label>
                <span class="detail-value">{{ selected.ofnar || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <label class="detail-label">Tipo:</label>
                <span class="detail-value">{{ selected.tpr || 'N/A' }}</span>
              </div>
            </div>
          </div>

          <div class="detail-section" v-if="selected.observr && selected.observr.trim()">
            <h6 class="detail-section-title">Observaciones</h6>
            <div class="detail-observation">
              {{ selected.observr }}
            </div>
          </div>
        </div>
      </Modal>
    </div>


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'ConsReq400'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Consulta Requerimientos 400'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'ConsReq400'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Consulta Requerimientos 400'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const BASE_DB = 'multas_reglamentos'
const OP_CONSREQ400 = 'RECAUDADORA_CONSREQ400'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const filters = ref({ cuenta: '', ejercicio: 2024 })
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const rows = ref([])

const showDetail = ref(false)
const selected = ref(null)

async function reload() {
  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') },
    { nombre: 'p_ejercicio', tipo: 'int', valor: Number(filters.value.ejercicio || 0) },
    { nombre: 'p_offset', tipo: 'int', valor: (page.value - 1) * pageSize.value },
    { nombre: 'p_limit', tipo: 'int', valor: pageSize.value }
  ]
  showLoading('Consultando...', 'Por favor espere')
  try {
    const response = await execute(OP_CONSREQ400, BASE_DB, params, '', null, 'publico')
    console.log('Respuesta completa:', response)

    // Extraer datos con fallbacks
    const responseData = response?.eResponse?.data || response?.data || response
    const result = Array.isArray(responseData?.result) ? responseData.result :
                   Array.isArray(responseData?.rows) ? responseData.rows :
                   Array.isArray(responseData) ? responseData : []

    console.log('Registros extraídos:', result.length, result)
    rows.value = result
    total.value = result.length > 0 ? Number(result[0].total_count || result.length) : 0
  } catch (e) {
    console.error('Error al consultar requerimientos:', e)
    rows.value = []
    total.value = 0
  } finally {
    hideLoading()
  }
}

function limpiar() {
  filters.value = { cuenta: '', ejercicio: 2024 }
  page.value = 1
  rows.value = []
  total.value = 0
}

function go(p) { page.value = p; reload() }
function openDetail(r) { selected.value = r; showDetail.value = true }
</script>

