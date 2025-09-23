<template>
  <div class="edo-cuenta-page">
    <h1>Estado de Cuenta - Regularización de Predios</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Estado de Cuenta</li>
      </ol>
    </nav>
    <form @submit.prevent="consultarEdoCuenta">
      <div class="form-group">
        <label for="tipo">Tipo</label>
        <select v-model="form.tipo" @change="onTipoChange" class="form-control" required>
          <option value="" disabled>Seleccione tipo</option>
          <option v-for="t in tipos" :key="t.tipo" :value="t.tipo">{{ t.tipo }} - {{ t.descripcion }}</option>
        </select>
      </div>
      <div class="form-group">
        <label for="subtipo">Subtipo</label>
        <select v-model="form.subtipo" class="form-control" required>
          <option value="" disabled>Seleccione subtipo</option>
          <option v-for="s in subtipos" :key="s.subtipo" :value="s.subtipo">{{ s.subtipo }} - {{ s.desc_subtipo }}</option>
        </select>
      </div>
      <button type="submit" class="btn btn-primary">Consultar Estado de Cuenta</button>
    </form>

    <div v-if="edoCuenta.length > 0" class="mt-4">
      <h3>Convenios encontrados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Manzana</th>
            <th>Lote</th>
            <th>Letra</th>
            <th>Nombre</th>
            <th>Calle</th>
            <th>Num. Ext.</th>
            <th>Num. Int.</th>
            <th>Inciso</th>
            <th>Cantidad Total</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="c in edoCuenta" :key="c.id_conv_resto">
            <td>{{ c.manzana }}</td>
            <td>{{ c.lote }}</td>
            <td>{{ c.letra }}</td>
            <td>{{ c.nombre }}</td>
            <td>{{ c.calle }}</td>
            <td>{{ c.num_exterior }}</td>
            <td>{{ c.num_interior }}</td>
            <td>{{ c.inciso }}</td>
            <td>{{ c.cantidad_total | currency }}</td>
            <td>
              <button class="btn btn-link btn-sm" @click="verDetalle(c)">Ver Detalle</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="detalleConvenio" class="mt-4">
      <h4>Detalle de Convenio</h4>
      <div class="row">
        <div class="col-md-6">
          <h5>Pagos</h5>
          <table class="table table-sm table-striped">
            <thead>
              <tr>
                <th>Parcialidad</th>
                <th>Fecha</th>
                <th>Rec.</th>
                <th>Caja</th>
                <th>Operación</th>
                <th>Importe</th>
                <th>Recargo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="p in pagos" :key="p.pago_parcial">
                <td>{{ p.pago_parcial }}</td>
                <td>{{ p.fecha_pago }}</td>
                <td>{{ p.oficina_pago }}</td>
                <td>{{ p.caja_pago }}</td>
                <td>{{ p.operacion_pago }}</td>
                <td>{{ p.importe_pago | currency }}</td>
                <td>{{ p.importe_recargo | currency }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="col-md-6">
          <h5>Adeudos</h5>
          <table class="table table-sm table-striped">
            <thead>
              <tr>
                <th>Parcialidad</th>
                <th>Importe</th>
                <th>Fecha Venc.</th>
                <th>Recargos</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="a in adeudos" :key="a.pago_parcial">
                <td>{{ a.pago_parcial }}</td>
                <td>{{ a.importe | currency }}</td>
                <td>{{ a.fecha_venc }}</td>
                <td>{{ a.recargos | currency }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <button class="btn btn-secondary mt-3" @click="detalleConvenio = null">Cerrar Detalle</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EdoCuentaPage',
  data() {
    return {
      tipos: [],
      subtipos: [],
      form: {
        tipo: '',
        subtipo: ''
      },
      edoCuenta: [],
      detalleConvenio: null,
      pagos: [],
      adeudos: []
    };
  },
  filters: {
    currency(val) {
      if (!val) return '$0.00';
      return '$' + parseFloat(val).toLocaleString('es-MX', {minimumFractionDigits: 2});
    }
  },
  created() {
    this.loadTipos();
  },
  methods: {
    async loadTipos() {
      const res = await this.api('getTipos', {});
      if (res.status === 'ok') this.tipos = res.data;
    },
    async onTipoChange() {
      this.form.subtipo = '';
      this.subtipos = [];
      if (!this.form.tipo) return;
      const res = await this.api('getSubTipos', {tipo: this.form.tipo});
      if (res.status === 'ok') this.subtipos = res.data;
    },
    async consultarEdoCuenta() {
      this.edoCuenta = [];
      this.detalleConvenio = null;
      const res = await this.api('getEdoCuenta', {
        tipo: this.form.tipo,
        subtipo: this.form.subtipo
      });
      if (res.status === 'ok') this.edoCuenta = res.data;
    },
    async verDetalle(convenio) {
      this.detalleConvenio = convenio;
      const pagosRes = await this.api('getPagos', {id_conv_resto: convenio.id_conv_resto});
      this.pagos = pagosRes.status === 'ok' ? pagosRes.data : [];
      const adeudosRes = await this.api('getAdeudos', {id_conv_resto: convenio.id_conv_resto});
      this.adeudos = adeudosRes.status === 'ok' ? adeudosRes.data : [];
    },
    async api(action, params) {
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({eRequest: {action, params}})
        });
        const data = await resp.json();
        return data.eResponse;
      } catch (e) {
        return {status: 'error', message: e.message, data: null};
      }
    }
  }
}
</script>

<style scoped>
.edo-cuenta-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
