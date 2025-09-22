<template>
  <div class="rpt-listaxregpub-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de Registros Públicos</li>
      </ol>
    </nav>
    <h1>Listado de Registros de Mercados con Requerimientos</h1>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row">
        <div class="col-md-3">
          <label for="vigencia">Vigencia</label>
          <select v-model="filters.vigencia" class="form-control" id="vigencia">
            <option value="todas">Todas</option>
            <option value="1">Vigente</option>
            <option value="2">Pagado</option>
            <option value="3">Cancelado</option>
            <option value="P">Pendiente</option>
          </select>
        </div>
        <div class="col-md-3">
          <label for="clave_practicado">Clave Practicado</label>
          <input v-model="filters.clave_practicado" class="form-control" id="clave_practicado" placeholder="todas o clave específica">
        </div>
        <div class="col-md-3">
          <label for="numesta">No. Estacionamiento</label>
          <input v-model="filters.numesta" class="form-control" id="numesta" placeholder="todas o número">
        </div>
        <div class="col-md-3 align-self-end">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>

    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>

    <div v-if="reportData.length">
      <table class="table table-bordered table-sm table-hover">
        <thead class="thead-light">
          <tr>
            <th>Folio</th>
            <th>Fecha Emisión</th>
            <th>Clave Practicado</th>
            <th>Fecha Practicado</th>
            <th>Hora</th>
            <th>Ejecutor</th>
            <th>Fecha Entrega</th>
            <th>Nombre</th>
            <th>Fecha Pago</th>
            <th>Recaudadora</th>
            <th>Caja</th>
            <th>Operación</th>
            <th>Adeudo</th>
            <th>Recargos</th>
            <th>Multas</th>
            <th>Gastos</th>
            <th>Porc. Multa</th>
            <th>Importe Pago</th>
            <th>Observaciones</th>
            <th>Zona</th>
            <th>Vigencia</th>
            <th>Vig. Reg</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reportData" :key="row.id">
            <td>{{ row.folio }}</td>
            <td>{{ formatDate(row.fecha_emision) }}</td>
            <td>{{ row.clave_practicado }}</td>
            <td>{{ formatDate(row.fecha_practicado) }}</td>
            <td>{{ formatTime(row.hora) }}</td>
            <td>{{ row.ejecutor }}</td>
            <td>{{ formatDate(row.fecha_entrega1) }}</td>
            <td>{{ row.nombre_1 }}</td>
            <td>{{ formatDate(row.fecha_pago) }}</td>
            <td>{{ row.recaudadora }}</td>
            <td>{{ row.caja }}</td>
            <td>{{ row.operacion }}</td>
            <td>{{ formatCurrency(row.importe_global) }}</td>
            <td>{{ formatCurrency(row.importe_recargo) }}</td>
            <td>{{ formatCurrency(row.importe_multa) }}</td>
            <td>{{ formatCurrency(row.importe_gastos) }}</td>
            <td>{{ row.porcentaje_multa }}%</td>
            <td>{{ formatCurrency(row.importe_pago) }}</td>
            <td>{{ row.observaciones }}</td>
            <td>{{ row.zona_1 }}</td>
            <td>{{ row.vigencia }}</td>
            <td>{{ row.vigreg }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total registros:</strong> {{ reportData.length }}
      </div>
      <div class="mt-2">
        <strong>Sumas:</strong>
        <span class="ml-2">Adeudo: {{ formatCurrency(sum('importe_global')) }}</span>
        <span class="ml-2">Recargos: {{ formatCurrency(sum('importe_recargo')) }}</span>
        <span class="ml-2">Multas: {{ formatCurrency(sum('importe_multa')) }}</span>
        <span class="ml-2">Gastos: {{ formatCurrency(sum('importe_gastos')) }}</span>
        <span class="ml-2">General: {{ formatCurrency(sumGeneral()) }}</span>
      </div>
    </div>
    <div v-else-if="!loading && !error">
      <div class="alert alert-warning">No hay datos para los filtros seleccionados.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptListaxRegPubPage',
  data() {
    return {
      filters: {
        vigencia: 'todas',
        clave_practicado: 'todas',
        numesta: 'todas',
      },
      reportData: [],
      loading: false,
      error: '',
      usuario_id_rec: null // Debe obtenerse del contexto de usuario autenticado
    };
  },
  created() {
    // Aquí deberías obtener usuario_id_rec del store o API de usuario
    // this.usuario_id_rec = ...
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = [];
      try {
        // Simulación: usuario_id_rec debe venir del contexto de autenticación
        const usuario_id_rec = this.usuario_id_rec || 1;
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: JSON.stringify({
            eRequest: 'RptListaxRegPub.getReport',
            params: {
              vigencia: this.filters.vigencia,
              clave_practicado: this.filters.clave_practicado,
              numesta: this.filters.numesta,
              usuario_id_rec: usuario_id_rec
            }
          })
        });
        const result = await response.json();
        if (result.success) {
          this.reportData = result.data;
        } else {
          this.error = result.message || 'Error al obtener datos';
        }
      } catch (err) {
        this.error = err.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    },
    formatDate(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    },
    formatTime(val) {
      if (!val) return '';
      const d = new Date(val);
      return d.toLocaleTimeString();
    },
    formatCurrency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    sum(field) {
      return this.reportData.reduce((acc, row) => acc + (Number(row[field]) || 0), 0);
    },
    sumGeneral() {
      return this.sum('importe_global') + this.sum('importe_multa') + this.sum('importe_recargo') + this.sum('importe_gastos');
    }
  }
}
</script>

<style scoped>
.rpt-listaxregpub-page {
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
}
</style>
