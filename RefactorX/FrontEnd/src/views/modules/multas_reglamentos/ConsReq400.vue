<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-invoice" /></div>
      <div class="module-view-info">
        <h1>Consulta Requerimientos 400</h1>
        <p>Consulta con filtros y paginación server-side</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input class="municipal-form-control" v-model="filters.cuenta" placeholder="Clave cuenta" @keyup.enter="reload" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input class="municipal-form-control" type="number" v-model.number="filters.ejercicio" @keyup.enter="reload" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload">
              <font-awesome-icon icon="search" /> Buscar
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
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import Modal from '@/components/common/Modal.vue'

const BASE_DB = 'multas_reglamentos'
const OP_CONSREQ400 = 'RECAUDADORA_CONSREQ400'
const SCHEMA = 'multas_reglamentos'

const { loading, execute } = useApi()

const filters = ref({ cuenta: '', ejercicio: new Date().getFullYear() })
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
  try {
    const data = await execute(OP_CONSREQ400, BASE_DB, params, '', null, SCHEMA)
    const result = Array.isArray(data?.result) ? data.result : Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
    rows.value = result
    total.value = result.length > 0 ? Number(result[0].total_count || result.length) : 0
  } catch (e) {
    rows.value = []
    total.value = 0
  }
}

function go(p) { page.value = p; reload() }
function openDetail(r) { selected.value = r; showDetail.value = true }

reload()
</script>

<style scoped>
.detail-content {
  padding: 0.5rem 0;
}

.detail-section {
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e0e0e0;
}

.detail-section:last-child {
  border-bottom: none;
  margin-bottom: 0;
}

.detail-section-title {
  color: #2c5282;
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #3b82f6;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 0.75rem;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.detail-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.detail-value {
  font-size: 0.95rem;
  color: #1e293b;
  font-weight: 500;
  padding: 0.4rem 0.6rem;
  background-color: #f8fafc;
  border-radius: 4px;
  border-left: 3px solid #cbd5e1;
}

.detail-observation {
  background-color: #fffbeb;
  border-left: 4px solid #f59e0b;
  padding: 1rem;
  border-radius: 4px;
  color: #78350f;
  font-size: 0.95rem;
  line-height: 1.6;
}

.badge-activo {
  background-color: #10b981;
  color: white;
  padding: 0.4rem 0.8rem;
  border-radius: 4px;
  font-weight: 600;
  text-align: center;
  border-left: none;
}

.badge-pagado {
  background-color: #3b82f6;
  color: white;
  padding: 0.4rem 0.8rem;
  border-radius: 4px;
  font-weight: 600;
  text-align: center;
  border-left: none;
}

.badge-pendiente {
  background-color: #f59e0b;
  color: white;
  padding: 0.4rem 0.8rem;
  border-radius: 4px;
  font-weight: 600;
  text-align: center;
  border-left: none;
}

@media (max-width: 768px) {
  .detail-grid {
    grid-template-columns: 1fr;
  }
}
</style>
