<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="percent" /></div>
      <div class="module-view-info">
        <h1>Descuentos Multa Municipal</h1>
        <p>Consulta descuentos de multas municipales</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">ID Multa</label>
              <input class="municipal-form-control" v-model="filters.cuenta" @keyup.enter="reload" placeholder="Ej: 191, 224, 241" />
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
          <h5><font-awesome-icon icon="list" /> Descuentos</h5>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID Multa</th>
                  <th>Acta</th>
                  <th>Fecha</th>
                  <th>Contribuyente</th>
                  <th>Domicilio</th>
                  <th>Multa</th>
                  <th>Total</th>
                  <th>Tipo Desc.</th>
                  <th>Valor</th>
                  <th>Estado</th>
                  <th>Fecha Desc.</th>
                  <th>Observación</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="row-hover">
                  <td><code>{{ r.id_multa }}</code></td>
                  <td>{{ r.num_acta }}</td>
                  <td>{{ r.fecha_acta }}</td>
                  <td>{{ r.contribuyente }}</td>
                  <td>{{ r.domicilio }}</td>
                  <td>${{ r.multa }}</td>
                  <td>${{ r.total }}</td>
                  <td>{{ r.tipo_descto }}</td>
                  <td>{{ r.valor_descuento }}{{ r.tipo_descto === 'Porcentaje' ? '%' : '' }}</td>
                  <td><span :class="'badge badge-' + (r.estado_desc === 'Vigente' ? 'success' : r.estado_desc === 'Pagado' ? 'info' : 'secondary')">{{ r.estado_desc }}</span></td>
                  <td>{{ r.fecha_descuento }}</td>
                  <td>{{ r.observacion }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="12" class="text-center text-muted">Sin registros</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_LIST = 'RECAUDADORA_DESCMULTAMPALFRM'

const { loading, execute } = useApi()

const filters = ref({ cuenta: '' })
const rows = ref([])

const SCHEMA = 'multas_reglamentos'

async function reload() {
  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') }
  ]
  try {
    const data = await execute(OP_LIST, BASE_DB, params, '', null, SCHEMA)
    rows.value = Array.isArray(data?.result) ? data.result : Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
  } catch (e) {
    rows.value = []
  }
}

reload()
</script>
