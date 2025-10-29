<template>
  <div class="pagosdiv-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta de Pagos Diversos</li>
      </ol>
    </nav>
    <h2>Consulta de Pagos Diversos</h2>
    <form @submit.prevent="buscarPagos" class="mb-4">
      <div class="row">
        <div class="col-md-2">
          <label for="fecha">Fecha</label>
          <input type="date" v-model="form.fecha" id="fecha" class="form-control" />
        </div>
        <div class="col-md-2">
          <label for="recaud">Rec</label>
          <input type="text" v-model="form.recaud" id="recaud" class="form-control" maxlength="3" @keypress="soloNumeros($event)" />
        </div>
        <div class="col-md-2">
          <label for="caja">Caja</label>
          <input type="text" v-model="form.caja" id="caja" class="form-control" maxlength="2" />
        </div>
        <div class="col-md-2">
          <label for="folio">Folio</label>
          <input type="text" v-model="form.folio" id="folio" class="form-control" maxlength="8" @keypress="soloNumeros($event)" />
        </div>
        <div class="col-md-4">
          <label for="contribuyente">Nombre</label>
          <input type="text" v-model="form.contribuyente" id="contribuyente" class="form-control" />
        </div>
      </div>
      <div class="mt-3">
        <button type="submit" class="btn btn-primary">Buscar</button>
        <button type="button" class="btn btn-secondary ml-2" @click="limpiar">Limpiar</button>
      </div>
    </form>

    <div v-if="pagos.length > 0">
      <h4>Resultados</h4>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Fecha</th>
            <th>Rec</th>
            <th>Caja</th>
            <th>Folio</th>
            <th>Hora</th>
            <th>Cajero</th>
            <th>Importe</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="pago in pagos" :key="pago.cvepago">
            <td>{{ pago.fecha ? pago.fecha.substring(0,10) : '' }}</td>
            <td>{{ pago.recaud }}</td>
            <td>{{ pago.caja }}</td>
            <td>{{ pago.folio }}</td>
            <td>{{ pago.hora ? pago.hora.substring(11,19) : '' }}</td>
            <td>{{ pago.cajero }}</td>
            <td>{{ pago.importe | currency }}</td>
            <td>
              <button class="btn btn-link btn-sm" @click="verDetalle(pago)">Detalle</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="buscado">
      <div class="alert alert-warning">No existen recibos de diversos con este criterio.</div>
    </div>

    <div v-if="detalle">
      <h4>Detalle del Pago</h4>
      <div class="row">
        <div class="col-md-4">
          <strong>Nombre:</strong> {{ detalle.diversos[0]?.contribuyente || '' }}<br />
          <strong>Domicilio:</strong> {{ detalle.diversos[0]?.domicilio || '' }}<br />
        </div>
        <div class="col-md-8">
          <strong>Concepto:</strong>
          <div class="border p-2" style="white-space: pre-line;">{{ detalle.diversos[0]?.concepto || '' }}</div>
        </div>
      </div>
      <h5 class="mt-3">Aplicación</h5>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Cta Aplicación</th>
            <th>Importe</th>
            <th>Cancelado</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="a in detalle.auditoria" :key="a.cvectaapl">
            <td>{{ a.cvectaapl }}</td>
            <td>{{ a.monto | currency }}</td>
            <td>{{ a.cancelacion === 'S' ? 'Sí' : '' }}</td>
          </tr>
        </tbody>
      </table>
      <div v-if="detalle.pagoscan.length">
        <h5>Cancelación</h5>
        <div>
          <strong>Fecha Cancelación:</strong> {{ detalle.pagoscan[0]?.fechacan ? detalle.pagoscan[0].fechacan.substring(0,10) : '' }}<br />
          <strong>Autorizó:</strong> {{ detalle.pagoscan[0]?.autorizo || '' }}
        </div>
      </div>
      <button class="btn btn-secondary mt-3" @click="cerrarDetalle">Cerrar Detalle</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PagosDivFrm',
  data() {
    return {
      form: {
        fecha: '',
        recaud: '',
        caja: '',
        folio: '',
        contribuyente: ''
      },
      pagos: [],
      detalle: null,
      buscado: false
    };
  },
  methods: {
    soloNumeros(e) {
      const char = String.fromCharCode(e.keyCode);
      if (!/[0-9]/.test(char) && e.keyCode !== 8 && e.keyCode !== 13) {
        e.preventDefault();
        alert('Solo puedes teclear números');
      }
    },
    async buscarPagos() {
      this.detalle = null;
      this.buscado = false;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'buscar_pagos_diversos',
            params: {
              fecha: this.form.fecha,
              recaud: this.form.recaud,
              caja: this.form.caja,
              folio: this.form.folio,
              contribuyente: this.form.contribuyente
            }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.pagos = data.data || [];
        } else {
          this.pagos = [];
          alert(data.message || 'Error en la búsqueda');
        }
        this.buscado = true;
      } catch (err) {
        alert('Error de comunicación con el servidor');
      }
    },
    async verDetalle(pago) {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'detalle_pago_diverso',
            params: { cvepago: pago.cvepago }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.detalle = data.data;
        } else {
          alert(data.message || 'Error al obtener detalle');
        }
      } catch (err) {
        alert('Error de comunicación con el servidor');
      }
    },
    cerrarDetalle() {
      this.detalle = null;
    },
    limpiar() {
      this.form = { fecha: '', recaud: '', caja: '', folio: '', contribuyente: '' };
      this.pagos = [];
      this.detalle = null;
      this.buscado = false;
    }
  },
  filters: {
    currency(value) {
      if (typeof value !== 'number') return value;
      return '$' + value.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.pagosdiv-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
