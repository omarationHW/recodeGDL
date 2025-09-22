<template>
  <div class="pagos-con-fpgo-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta de Pagos por Fecha de Pago</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header d-flex align-items-center">
        <h5 class="mb-0 flex-grow-1">Consulta de Pagos por Fecha de Pago</h5>
        <button class="btn btn-primary ms-2" @click="buscarPagos"><i class="bi bi-search"></i> Buscar</button>
      </div>
      <div class="card-body row g-3 align-items-center">
        <div class="col-auto">
          <label for="fecha" class="col-form-label">Fecha de Pago</label>
        </div>
        <div class="col-auto">
          <input type="date" v-model="fecha" id="fecha" class="form-control" />
        </div>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="pagos.length > 0" class="card">
      <div class="card-header">Resultados</div>
      <div class="card-body p-0">
        <table class="table table-striped table-hover mb-0">
          <thead>
            <tr>
              <th>Contrato</th>
              <th>Periodo Pago</th>
              <th>Operación</th>
              <th>Excedencias</th>
              <th>Importe</th>
              <th>Vigencia</th>
              <th>Fecha/Hora Pago</th>
              <th>Recaudadora</th>
              <th>Caja</th>
              <th>Cons. Operación</th>
              <th>Folio Recibo</th>
              <th>Detalle Contrato</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="pago in pagos" :key="pago.control_contrato + '-' + pago.aso_mes_pago + '-' + pago.ctrol_operacion">
              <td>{{ pago.control_contrato }}</td>
              <td>{{ pago.aso_mes_pago | formatPeriodo }}</td>
              <td>{{ pago.descripcion }}</td>
              <td>{{ pago.exedencias }}</td>
              <td>{{ pago.importe | currency }}</td>
              <td>{{ pago.status_vigencia }}</td>
              <td>{{ pago.fecha_hora_pago | datetime }}</td>
              <td>{{ pago.recaudadora }}</td>
              <td>{{ pago.caja }}</td>
              <td>{{ pago.consec_operacion }}</td>
              <td>{{ pago.folio_rcbo }}</td>
              <td>
                <button class="btn btn-link btn-sm" @click="verContrato(pago.control_contrato)">Ver</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="contratoDetalle" class="modal fade show d-block" tabindex="-1" style="background:rgba(0,0,0,0.2)">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Detalle de Contrato #{{ contratoDetalle.control_contrato }}</h5>
            <button type="button" class="btn-close" @click="contratoDetalle = null"></button>
          </div>
          <div class="modal-body">
            <table class="table table-bordered">
              <tbody>
                <tr><th>Contrato</th><td>{{ contratoDetalle.num_contrato }}</td></tr>
                <tr><th>Tipo Aseo</th><td>{{ contratoDetalle.tipo_aseo }} - {{ contratoDetalle.descripcion }}</td></tr>
                <tr><th>Recolección</th><td>{{ contratoDetalle.cantidad_recolec }} x {{ contratoDetalle.costo_unidad | currency }}</td></tr>
                <tr><th>Inicio Obligación</th><td>{{ contratoDetalle.aso_mes_oblig | formatPeriodo }}</td></tr>
                <!-- Agregar más campos según necesidad -->
              </tbody>
            </table>
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" @click="contratoDetalle = null">Cerrar</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PagosConFPgoPage',
  data() {
    return {
      fecha: new Date().toISOString().substr(0, 10),
      pagos: [],
      loading: false,
      error: '',
      contratoDetalle: null
    };
  },
  methods: {
    async buscarPagos() {
      this.loading = true;
      this.error = '';
      this.pagos = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getPagosByFecha',
            params: { fecha: this.fecha }
          }
        });
        if (res.data.eResponse.success) {
          this.pagos = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message || 'Error al consultar pagos';
        }
      } catch (e) {
        this.error = e.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    },
    async verContrato(control_contrato) {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getContratoDetalle',
            params: { control_contrato }
          }
        });
        if (res.data.eResponse.success && res.data.eResponse.data.length > 0) {
          this.contratoDetalle = res.data.eResponse.data[0];
        } else {
          this.error = res.data.eResponse.message || 'No se encontró el contrato';
        }
      } catch (e) {
        this.error = e.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    }
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    },
    datetime(val) {
      if (!val) return '';
      return new Date(val).toLocaleString('es-MX');
    },
    formatPeriodo(val) {
      if (!val) return '';
      // Espera formato YYYY-MM
      if (typeof val === 'string' && val.length >= 7) {
        const [y, m] = val.split('-');
        return `${m}/${y}`;
      }
      try {
        const d = new Date(val);
        return `${d.getMonth() + 1}/${d.getFullYear()}`;
      } catch (e) {
        return val;
      }
    }
  }
};
</script>

<style scoped>
.pagos-con-fpgo-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.modal {
  display: block;
  background: rgba(0,0,0,0.2);
}
</style>
