<template>
  <div class="individual-diversos-page">
    <h1>Consulta de Convenios Diversos</h1>
    <div class="search-section">
      <form @submit.prevent="buscarConvenio">
        <div class="form-row">
          <label>Tipo:</label>
          <select v-model="form.tipo" @change="onTipoChange">
            <option v-for="t in tipos" :key="t.tipo" :value="t.tipo">{{ t.tipo }} - {{ t.descripcion }}</option>
          </select>
          <label>Subtipo:</label>
          <select v-model="form.subtipo">
            <option v-for="s in subtipos" :key="s.subtipo" :value="s.subtipo">{{ s.subtipo }} - {{ s.desc_subtipo }}</option>
          </select>
        </div>
        <div class="form-row" v-if="form.tipo == 14">
          <label>Manzana:</label>
          <input v-model="form.manzana" />
          <label>Lote:</label>
          <input v-model="form.lote" type="number" />
          <label>Letra:</label>
          <input v-model="form.letra" maxlength="1" />
        </div>
        <div class="form-row" v-else>
          <label>Letras Oficio:</label>
          <input v-model="form.letras_exp" maxlength="3" />
          <label>Folio Oficio:</label>
          <input v-model="form.numero_exp" type="number" />
          <label>Año Oficio:</label>
          <input v-model="form.axo_exp" type="number" />
        </div>
        <button type="submit">Buscar Convenio</button>
      </form>
    </div>
    <div v-if="convenio" class="convenio-section">
      <h2>Datos del Convenio</h2>
      <table class="convenio-table">
        <tr><th>Nombre</th><td>{{ convenio.nombre }}</td></tr>
        <tr><th>Calle</th><td>{{ convenio.calle }}</td></tr>
        <tr><th>Exterior</th><td>{{ convenio.num_exterior }}</td></tr>
        <tr><th>Interior</th><td>{{ convenio.num_interior }}</td></tr>
        <tr><th>Inciso</th><td>{{ convenio.inciso }}</td></tr>
        <tr><th>Fecha Inicio</th><td>{{ convenio.fecha_inicio }}</td></tr>
        <tr><th>Fecha Vencimiento</th><td>{{ convenio.fecha_venc }}</td></tr>
        <tr><th>Cantidad Total</th><td>{{ convenio.cantidad_total | currency }}</td></tr>
        <tr><th>Pago Inicial</th><td>{{ convenio.cantidad_inicio | currency }}</td></tr>
        <tr><th>Pago Parcial</th><td>{{ convenio.pago_parcial | currency }}</td></tr>
        <tr><th>Pago Final</th><td>{{ convenio.pago_final | currency }}</td></tr>
        <tr><th>Total Pagos</th><td>{{ convenio.total_pagos }}</td></tr>
        <tr><th>Tipo de Pago</th><td>{{ convenio.tipo_pago }}</td></tr>
        <tr><th>Vigencia</th><td>{{ convenio.vigencia }}</td></tr>
        <tr><th>Observaciones</th><td>{{ convenio.observaciones }}</td></tr>
      </table>
      <div class="actions">
        <button @click="cargarAdeudos">Ver Adeudos</button>
        <button @click="cargarPagos">Ver Pagos</button>
        <button @click="cargarReferencias">Ver Referencias</button>
      </div>
    </div>
    <div v-if="adeudos && adeudos.length" class="adeudos-section">
      <h3>Adeudos</h3>
      <table class="data-table">
        <thead>
          <tr>
            <th>Parcialidad</th>
            <th>Importe</th>
            <th>Interés</th>
            <th>Recargos</th>
            <th>Total</th>
            <th>Vencimiento</th>
            <th>Periodos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="a in adeudos" :key="a.id_adeudo">
            <td>{{ a.pago_parcial }}</td>
            <td>{{ a.importe | currency }}</td>
            <td>{{ a.Interescalc | currency }}</td>
            <td>{{ a.recargos | currency }}</td>
            <td>{{ a.total | currency }}</td>
            <td>{{ a.fecha_venc }}</td>
            <td>{{ a.periodos }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="pagos && pagos.length" class="pagos-section">
      <h3>Pagos Realizados</h3>
      <table class="data-table">
        <thead>
          <tr>
            <th>Fecha</th>
            <th>Oficina</th>
            <th>Caja</th>
            <th>Operación</th>
            <th>Parcialidad</th>
            <th>Importe</th>
            <th>Recargo</th>
            <th>Intereses</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in pagos" :key="p.id_conv_pago">
            <td>{{ p.fecha_pago }}</td>
            <td>{{ p.oficina_pago }}</td>
            <td>{{ p.caja_pago }}</td>
            <td>{{ p.operacion_pago }}</td>
            <td>{{ p.pago_parcial }}</td>
            <td>{{ p.importe_pago | currency }}</td>
            <td>{{ p.importe_recargo | currency }}</td>
            <td>{{ p.intereses | currency }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="referencias && referencias.length" class="referencias-section">
      <h3>Referencias</h3>
      <table class="data-table">
        <thead>
          <tr>
            <th>Módulo</th>
            <th>Referencia</th>
            <th>Periodos</th>
            <th>Impuesto</th>
            <th>Recargos</th>
            <th>Gastos</th>
            <th>Multa</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in referencias" :key="r.id_control">
            <td>{{ r.modulo }}</td>
            <td>{{ r.referencia }}</td>
            <td>{{ r.periodos }}</td>
            <td>{{ r.impuesto | currency }}</td>
            <td>{{ r.recargos | currency }}</td>
            <td>{{ r.gastos | currency }}</td>
            <td>{{ r.multa | currency }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="error" class="error-message">
      <p>{{ error }}</p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'IndividualDiversosPage',
  data() {
    return {
      tipos: [],
      subtipos: [],
      form: {
        tipo: '',
        subtipo: '',
        manzana: '',
        lote: '',
        letra: '',
        letras_exp: '',
        numero_exp: '',
        axo_exp: ''
      },
      convenio: null,
      adeudos: null,
      pagos: null,
      referencias: null,
      error: null
    }
  },
  created() {
    this.cargarTipos();
  },
  methods: {
    async cargarTipos() {
      const res = await this.api('getTipos');
      this.tipos = res.tipos;
    },
    async onTipoChange() {
      this.form.subtipo = '';
      this.subtipos = [];
      if (this.form.tipo) {
        const res = await this.api('getSubTipos', { tipo: this.form.tipo });
        this.subtipos = res.subtipos;
      }
    },
    async buscarConvenio() {
      this.error = null;
      this.convenio = null;
      this.adeudos = null;
      this.pagos = null;
      this.referencias = null;
      try {
        const params = { ...this.form };
        const res = await this.api('buscarConvenio', params);
        this.convenio = res.convenio;
      } catch (e) {
        this.error = e.message || e;
      }
    },
    async cargarAdeudos() {
      if (!this.convenio) return;
      const id_conv_resto = this.convenio.id_conv_resto;
      const res = await this.api('getAdeudos', { id_conv_resto });
      this.adeudos = res.adeudos;
    },
    async cargarPagos() {
      if (!this.convenio) return;
      const id_conv_resto = this.convenio.id_conv_resto;
      const res = await this.api('getPagos', { id_conv_resto });
      this.pagos = res.pagos;
    },
    async cargarReferencias() {
      if (!this.convenio) return;
      const id_conv_resto = this.convenio.id_conv_resto;
      const res = await this.api('getReferencias', { id_conv_resto });
      this.referencias = res.referencias;
    },
    async api(action, params = {}) {
      const response = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action, params } })
      });
      const data = await response.json();
      if (data.eResponse && data.eResponse.error) throw new Error(data.eResponse.error);
      return data.eResponse;
    }
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
}
</script>

<style scoped>
.individual-diversos-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.search-section {
  background: #f8f8f8;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 2rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.convenio-section {
  background: #f0f6ff;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 2rem;
}
.convenio-table th {
  text-align: left;
  padding-right: 1rem;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 2rem;
}
.data-table th, .data-table td {
  border: 1px solid #ddd;
  padding: 0.5rem;
}
.data-table th {
  background: #e0eaff;
}
.actions {
  margin-top: 1rem;
  display: flex;
  gap: 1rem;
}
.error-message {
  color: red;
  font-weight: bold;
}
</style>
