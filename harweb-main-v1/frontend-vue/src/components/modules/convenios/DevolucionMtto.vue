<template>
  <div class="devolucion-mtto-page">
    <h1>Captura de Devoluciones de Pago</h1>
    <form @submit.prevent="onBuscarContrato">
      <fieldset>
        <legend>Contrato</legend>
        <label>Colonia <input v-model="form.colonia" type="number" required @keypress="onlyNumber($event)" /></label>
        <label>Calle <input v-model="form.calle" type="number" required @keypress="onlyNumber($event)" /></label>
        <label>Folio <input v-model="form.folio" type="number" required @keypress="onlyNumber($event)" /></label>
        <button type="submit">Buscar</button>
      </fieldset>
    </form>

    <div v-if="contrato">
      <fieldset>
        <legend>Datos Generales</legend>
        <div><b>Nombre:</b> {{ contrato.nombre }}</div>
        <div><b>Domicilio:</b> {{ contrato.desc_calle }} {{ contrato.numero }}</div>
        <div><b>Colonia:</b> {{ contrato.descripcion_1 }}</div>
        <div><b>Servicio:</b> {{ contrato.descripcion_2 }}</div>
        <div><b>Fondo:</b> {{ contrato.descripcion }}</div>
        <div><b>A\u00f1o Obra:</b> {{ contrato.axo_obra }}</div>
        <div><b>Metros2:</b> {{ contrato.metros2 }}</div>
        <div><b>Firmado:</b> {{ contrato.fecha_firma }}</div>
        <div><b>Costo Contrato:</b> {{ contrato.pago_total | currency }}</div>
        <div><b>Pagos:</b> {{ pagos | currency }}</div>
        <div><b>Saldo:</b> {{ (contrato.pago_total - pagos) | currency }}</div>
      </fieldset>

      <fieldset>
        <legend>Devoluciones Existentes</legend>
        <table class="table">
          <thead>
            <tr>
              <th>Control</th>
              <th>Remesa</th>
              <th>Oficio</th>
              <th>Folio</th>
              <th>Fecha Solicitud</th>
              <th>RFC</th>
              <th>Importe</th>
              <th>Observaci\u00f3n</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="dev in devoluciones" :key="dev.id_devolucion">
              <td>{{ dev.id_devolucion }}</td>
              <td>{{ dev.remesa }}</td>
              <td>{{ dev.oficio }}</td>
              <td>{{ dev.folio }}</td>
              <td>{{ dev.fecha_solicitud }}</td>
              <td>{{ dev.rfc }}</td>
              <td>{{ dev.importe | currency }}</td>
              <td>{{ dev.observacion }}</td>
              <td>
                <button @click="editDevolucion(dev)">Editar</button>
                <button @click="deleteDevolucion(dev)">Eliminar</button>
              </td>
            </tr>
          </tbody>
        </table>
      </fieldset>

      <fieldset>
        <legend>{{ editing ? 'Modificar Devoluci\u00f3n' : 'Nueva Devoluci\u00f3n' }}</legend>
        <form @submit.prevent="onSubmit">
          <label>Remesa <input v-model="devolucion.remesa" maxlength="20" required /></label>
          <label>Oficio <input v-model="devolucion.oficio" maxlength="20" required /></label>
          <label>Folio <input v-model="devolucion.folio" maxlength="15" required /></label>
          <label>Fecha Solicitud <input v-model="devolucion.fecha_solicitud" type="date" required /></label>
          <label>RFC <input v-model="devolucion.rfc" maxlength="20" /></label>
          <label>Importe <input v-model.number="devolucion.importe" type="number" step="0.01" min="0" required /></label>
          <label>Observaciones <input v-model="devolucion.observacion" maxlength="60" /></label>
          <div>
            <button type="submit">{{ editing ? 'Modificar' : 'Agregar' }}</button>
            <button type="button" @click="resetForm">Cancelar</button>
          </div>
        </form>
      </fieldset>
    </div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="success" class="success">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'DevolucionMttoPage',
  data() {
    return {
      form: {
        colonia: '',
        calle: '',
        folio: ''
      },
      contrato: null,
      devoluciones: [],
      pagos: 0,
      devolucion: {
        id_devolucion: null,
        remesa: '',
        oficio: '',
        folio: '',
        fecha_solicitud: '',
        rfc: '',
        importe: 0,
        observacion: ''
      },
      editing: false,
      error: '',
      success: ''
    };
  },
  methods: {
    onlyNumber(e) {
      if (!/[0-9]/.test(e.key)) e.preventDefault();
    },
    async onBuscarContrato() {
      this.error = '';
      this.success = '';
      this.contrato = null;
      this.devoluciones = [];
      this.pagos = 0;
      // 1. Buscar contrato
      const res = await this.api('get_contrato', {
        colonia: this.form.colonia,
        calle: this.form.calle,
        folio: this.form.folio
      });
      if (!res.success || !res.data) {
        this.error = 'Contrato no encontrado o cancelado';
        return;
      }
      this.contrato = res.data;
      // 2. Cargar devoluciones
      await this.loadDevoluciones();
      // 3. Cargar pagos
      const pagosRes = await this.api('get_pagos', { id_convenio: this.contrato.id_convenio });
      this.pagos = pagosRes.data || 0;
      this.resetForm();
    },
    async loadDevoluciones() {
      if (!this.contrato) return;
      const res = await this.api('list_devoluciones', { id_convenio: this.contrato.id_convenio });
      this.devoluciones = res.data || [];
    },
    editDevolucion(dev) {
      this.devolucion = { ...dev };
      this.editing = true;
      this.error = '';
      this.success = '';
    },
    async deleteDevolucion(dev) {
      if (!confirm('¿Eliminar esta devolución?')) return;
      const res = await this.api('delete_devolucion', { id_devolucion: dev.id_devolucion });
      if (res.success) {
        this.success = 'Devolución eliminada correctamente';
        await this.loadDevoluciones();
        this.resetForm();
      } else {
        this.error = res.message || 'Error al eliminar';
      }
    },
    async onSubmit() {
      this.error = '';
      this.success = '';
      if (!this.contrato) {
        this.error = 'Debe buscar un contrato primero';
        return;
      }
      const payload = {
        ...this.devolucion,
        id_convenio: this.contrato.id_convenio,
        id_usuario: 1 // TODO: obtener usuario real
      };
      let res;
      if (this.editing) {
        res = await this.api('update_devolucion', payload);
      } else {
        res = await this.api('create_devolucion', payload);
      }
      if (res.success) {
        this.success = this.editing ? 'Devolución modificada' : 'Devolución agregada';
        await this.loadDevoluciones();
        this.resetForm();
      } else {
        this.error = res.message || 'Error al guardar';
      }
    },
    resetForm() {
      this.devolucion = {
        id_devolucion: null,
        remesa: '',
        oficio: '',
        folio: '',
        fecha_solicitud: '',
        rfc: '',
        importe: 0,
        observacion: ''
      };
      this.editing = false;
    },
    async api(action, payload) {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action, payload })
        });
        return await res.json();
      } catch (e) {
        return { success: false, message: e.message };
      }
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.devolucion-mtto-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 1.5rem;
}
fieldset {
  margin-bottom: 1.5rem;
  border: 1px solid #ccc;
  padding: 1rem;
}
label {
  display: inline-block;
  margin-right: 1rem;
  margin-bottom: 0.5rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.3rem 0.5rem;
}
.error { color: red; margin-top: 1rem; }
.success { color: green; margin-top: 1rem; }
</style>
