<template>
  <div class="multiple-fecha-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta Múltiple por Fecha de Pago</li>
      </ol>
    </nav>
    <h2>Consulta Múltiple por Fecha de Pago</h2>
    <form @submit.prevent="buscarPagos">
      <div class="form-row align-items-end">
        <div class="form-group col-md-3">
          <label for="fecha">Fecha de Pago</label>
          <input type="date" v-model="form.fecha" class="form-control" id="fecha" required />
        </div>
        <div class="form-group col-md-2">
          <label for="rec">Rec-Pago</label>
          <input type="number" v-model.number="form.rec" min="1" max="9" class="form-control" id="rec" required />
        </div>
        <div class="form-group col-md-2">
          <label for="caja">Caja</label>
          <input type="text" v-model="form.caja" maxlength="10" class="form-control" id="caja" required />
        </div>
        <div class="form-group col-md-2">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="my-3">
      <span class="spinner-border spinner-border-sm"></span> Buscando...
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="pagos.length > 0" class="table-responsive mt-4">
      <table class="table table-bordered table-sm table-hover">
        <thead class="thead-light">
          <tr>
            <th>Pag</th>
            <th>Fec Pag</th>
            <th>Ofna</th>
            <th>Caja</th>
            <th>Operac</th>
            <th>Folio</th>
            <th>Cem</th>
            <th>Clase</th>
            <th>Clase A</th>
            <th>Secc</th>
            <th>Secc A</th>
            <th>Linea</th>
            <th>Linea A</th>
            <th>Fosa</th>
            <th>Fosa A</th>
            <th>Desde</th>
            <th>Hasta</th>
            <th>Mantenimiento</th>
            <th>Recargos</th>
            <th>Vig</th>
            <th>Usuario</th>
            <th>Fec Mov</th>
            <th>Observ</th>
            <th>Acción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="pago in pagos" :key="pago.control_rcm + '-' + pago.fecing">
            <td>{{ pago.tipopag }}</td>
            <td>{{ formatDate(pago.fecing) }}</td>
            <td>{{ pago.recing }}</td>
            <td>{{ pago.cajing }}</td>
            <td>{{ pago.opcaja }}</td>
            <td>{{ pago.control_rcm }}</td>
            <td>{{ pago.cementerio }}</td>
            <td>{{ pago.clase }}</td>
            <td>{{ pago.clase_alfa }}</td>
            <td>{{ pago.seccion }}</td>
            <td>{{ pago.seccion_alfa }}</td>
            <td>{{ pago.linea }}</td>
            <td>{{ pago.linea_alfa }}</td>
            <td>{{ pago.fosa }}</td>
            <td>{{ pago.fosa_alfa }}</td>
            <td>{{ pago.axo_pago_desde }}</td>
            <td>{{ pago.axo_pago_hasta }}</td>
            <td>{{ pago.importe_anual }}</td>
            <td>{{ pago.importe_recargos }}</td>
            <td>{{ pago.vigencia }}</td>
            <td>{{ pago.usuario }}</td>
            <td>{{ formatDate(pago.fecha_mov) }}</td>
            <td>{{ pago.obser }}</td>
            <td>
              <button class="btn btn-link btn-sm" @click="verDetalle(pago.control_rcm)">Ver Detalle</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="detalle" class="modal fade show d-block" tabindex="-1" role="dialog" style="background:rgba(0,0,0,0.3)">
      <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Detalle de Pago Folio {{ detalle.control_rcm }}</h5>
            <button type="button" class="close" @click="detalle = null"><span>&times;</span></button>
          </div>
          <div class="modal-body">
            <pre>{{ detalle }}</pre>
            <!-- Aquí puedes mostrar los campos relevantes -->
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="detalle = null">Cerrar</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MultipleFechaPage',
  data() {
    return {
      form: {
        fecha: '',
        rec: 1,
        caja: 'A'
      },
      pagos: [],
      loading: false,
      error: '',
      detalle: null
    };
  },
  methods: {
    buscarPagos() {
      this.error = '';
      this.pagos = [];
      this.loading = true;
      this.detalle = null;
      this.$axios.post('/api/execute', {
        action: 'getPagosByFecha',
        params: {
          fecha: this.form.fecha,
          rec: this.form.rec,
          caja: this.form.caja
        }
      })
      .then(res => {
        if (res.data.success) {
          this.pagos = res.data.data;
        } else {
          this.error = res.data.message || 'Error en la consulta';
        }
      })
      .catch(err => {
        this.error = err.response?.data?.message || err.message;
      })
      .finally(() => {
        this.loading = false;
      });
    },
    verDetalle(control_rcm) {
      this.loading = true;
      this.$axios.post('/api/execute', {
        action: 'getPagoDetalle',
        params: { control_rcm }
      })
      .then(res => {
        if (res.data.success && res.data.data && res.data.data.length > 0) {
          this.detalle = res.data.data[0];
        } else {
          this.error = res.data.message || 'No se encontró el detalle';
        }
      })
      .catch(err => {
        this.error = err.response?.data?.message || err.message;
      })
      .finally(() => {
        this.loading = false;
      });
    },
    formatDate(date) {
      if (!date) return '';
      const d = new Date(date);
      return d.toLocaleDateString();
    }
  }
};
</script>

<style scoped>
.multiple-fecha-page {
  padding: 2rem;
}
.modal {
  display: block;
}
</style>
