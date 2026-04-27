<template>
  <div class="min-h-screen bg-gray-50">
    <nav class="bg-white shadow">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <h1 class="text-base sm:text-xl font-bold text-gray-900 truncate">Detail Invoice</h1>
          <div class="flex items-center gap-2 flex-shrink-0">
            <button
              @click="downloadPDF"
              :disabled="downloading"
              class="inline-flex items-center px-3 py-1.5 sm:px-4 sm:py-2 border border-transparent text-sm font-medium rounded-md text-white bg-orange-primary hover:bg-orange-dark disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span class="hidden sm:inline">{{
                downloading ? "Mengunduh..." : "Download PDF"
              }}</span>
              <span class="sm:hidden">{{ downloading ? "..." : "PDF" }}</span>
            </button>
            <router-link
              to="/invoices"
              class="inline-flex items-center px-3 py-1.5 sm:px-4 sm:py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
            >
              Kembali
            </router-link>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <div v-if="loading" class="text-center py-12">
          <div
            class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-orange-primary"
          ></div>
        </div>

        <div
          v-else-if="error"
          class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded"
        >
          {{ error }}
        </div>

        <div v-else-if="invoice" class="bg-white shadow rounded-lg">
          <div id="invoice-content" class="p-4 sm:p-8">
            <div
              class="flex flex-col sm:flex-row justify-between items-start gap-4 pb-6 mb-6 border-b-2 border-gray-200"
            >
              <!-- Kiri: logo & identitas perusahaan -->
              <div class="flex items-start gap-4">
                <img
                  src="@/assets/logo.jpeg"
                  alt="Catering Hanin Hanif"
                  class="w-28 h-28 object-contain rounded-2xl flex-shrink-0 border-2 border-orange-primary"
                />
                <div>
                  <h2 class="text-xl font-bold text-gray-900">Catering Hanin Hanif</h2>
                  <p class="text-gray-600 text-sm mt-1">Jl. Tamangapa V No. 12345</p>
                  <p class="text-gray-600 text-sm">Makassar 90235, Sulawesi Selatan</p>
                  <p class="text-gray-600 text-sm mt-1">Telp: (0411) 123-4567</p>
                  <p class="text-gray-600 text-sm">WA: 0812-3456-7890</p>
                </div>
              </div>

              <!-- Kanan: info invoice & pelanggan -->
              <div class="text-left sm:text-right w-full sm:w-auto">
                <div class="space-y-1 text-sm">
                  <div class="flex justify-between gap-8">
                    <span class="text-gray-500">No. Invoice</span>
                    <span class="text-gray-900 font-semibold">{{ invoice.invoice_number }}</span>
                  </div>
                  <div class="flex justify-between gap-8">
                    <span class="text-gray-500">Tanggal</span>
                    <span class="text-gray-900">{{ formatDate(invoice.invoice_date) }}</span>
                  </div>
                  <div class="flex justify-between gap-8">
                    <span class="text-gray-500">Kode Sales</span>
                    <span class="text-gray-900">{{ invoice.sales_code }}</span>
                  </div>
                  <div class="flex justify-between gap-8">
                    <span class="text-gray-500">PPN</span>
                    <span class="text-gray-900">{{
                      invoice.ppn_included ? "Included" : "Exclude"
                    }}</span>
                  </div>
                  <div class="flex justify-between gap-8">
                    <span class="text-gray-500">Pelanggan</span>
                    <span class="text-gray-900 font-semibold">{{ invoice.customer_name }}</span>
                  </div>
                  <div v-if="invoice.customer_address" class="flex justify-between gap-8">
                    <span class="text-gray-500">Alamat</span>
                    <span class="text-gray-600 whitespace-pre-line">{{
                      invoice.customer_address
                    }}</span>
                  </div>
                </div>
              </div>
            </div>

            <div class="overflow-x-auto mb-6">
              <table class="w-full">
                <thead>
                  <tr class="bg-gray-50 border-b-2 border-gray-200">
                    <th class="px-4 py-3 text-left text-sm font-medium text-gray-500 uppercase">
                      No
                    </th>
                    <th class="px-4 py-3 text-left text-sm font-medium text-gray-500 uppercase">
                      Item
                    </th>
                    <th class="px-4 py-3 text-center text-sm font-medium text-gray-500 uppercase">
                      Jumlah
                    </th>
                    <th class="px-4 py-3 text-right text-sm font-medium text-gray-500 uppercase">
                      Harga
                    </th>
                    <th class="px-4 py-3 text-right text-sm font-medium text-gray-500 uppercase">
                      Diskon
                    </th>
                    <th class="px-4 py-3 text-right text-sm font-medium text-gray-500 uppercase">
                      Total
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="(item, index) in invoice.items"
                    :key="item.id"
                    class="border-b border-gray-200"
                  >
                    <td class="px-4 py-3 text-sm text-gray-900">{{ Number(index) + 1 }}</td>
                    <td class="px-4 py-3 text-sm text-gray-900">{{ item.product_name }}</td>
                    <td class="px-4 py-3 text-sm text-gray-900 text-center">{{ item.quantity }}</td>
                    <td class="px-4 py-3 text-sm text-gray-900 text-right">
                      {{ formatCurrency(item.unit_price) }}
                    </td>
                    <td class="px-4 py-3 text-sm text-gray-600 text-right">
                      {{ item.discount > 0 ? formatCurrency(item.discount) : "-" }}
                    </td>
                    <td class="px-4 py-3 text-sm text-gray-900 font-medium text-right">
                      {{ formatCurrency(item.quantity * item.unit_price - item.discount) }}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div class="flex flex-col sm:flex-row justify-between items-start gap-4">
              <div class="text-sm pt-1">
                <span class="text-gray-600">Jumlah item: </span>
                <span class="text-gray-900 font-medium">
                  {{ invoice.items.reduce((sum, item) => sum + Number(item.quantity), 0) }}
                </span>
              </div>
              <div class="w-full sm:w-64">
                <div class="space-y-2">
                  <div class="flex justify-between text-sm">
                    <span class="text-gray-600">Sub Total</span>
                    <span class="text-gray-900">{{ formatCurrency(invoice.subtotal) }}</span>
                  </div>
                  <div class="flex justify-between text-sm">
                    <span class="text-gray-600">Potongan</span>
                    <span class="text-gray-900">{{ formatCurrency(invoice.discount_amount) }}</span>
                  </div>
                  <div class="flex justify-between text-sm">
                    <span class="text-gray-600">Total</span>
                    <span class="font-medium text-gray-900">{{
                      formatCurrency(invoice.total)
                    }}</span>
                  </div>
                  <div class="flex justify-between text-sm">
                    <span class="text-gray-600">DP PO</span>
                    <span class="text-gray-900">{{ formatCurrency(invoice.dp_po) }}</span>
                  </div>
                  <div class="flex justify-between text-sm border-t pt-2">
                    <span class="font-medium text-gray-900">Kredit</span>
                    <span class="font-bold text-gray-900">{{
                      formatCurrency(Math.max(0, invoice.total - invoice.dp_po))
                    }}</span>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-6 pt-6 border-t border-gray-200">
              <p class="text-sm text-gray-600">
                <span class="font-medium">Terbilang:</span>
                {{ numberToWords(Math.max(0, invoice.total - invoice.dp_po)) }}
              </p>
            </div>

            <div class="mt-8 pt-6 border-t border-gray-200">
              <h3 class="text-sm font-medium text-gray-500 uppercase mb-4">Informasi Pembayaran</h3>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 text-sm">
                <div>
                  <p class="text-gray-600">Bank BCA</p>
                  <p class="font-medium text-gray-900">No. Rek: 123-456-7890</p>
                  <p class="text-gray-600">a/n Catering Hanin Hanif</p>
                </div>
                <div>
                  <p class="text-gray-600">Bank Mandiri</p>
                  <p class="font-medium text-gray-900">No. Rek: 098-765-4321</p>
                  <p class="text-gray-600">a/n Catering Hanin Hanif</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import { useInvoices } from "@/composables/useInvoices";
import type { InvoiceWithItems } from "@/types";
import jsPDF from "jspdf";
import html2canvas from "html2canvas";

const route = useRoute();
const { fetchInvoice, numberToWords } = useInvoices();

const invoice = ref<InvoiceWithItems | null>(null);
const loading = ref(false);
const error = ref("");
const downloading = ref(false);

async function loadInvoice() {
  loading.value = true;
  error.value = "";
  try {
    invoice.value = await fetchInvoice(route.params.id as string);
  } catch (err: unknown) {
    error.value = err instanceof Error ? err.message : "Gagal memuat invoice";
  } finally {
    loading.value = false;
  }
}

async function downloadPDF() {
  if (!invoice.value) return;

  downloading.value = true;
  try {
    const element = document.getElementById("invoice-content");
    if (!element) return;

    // Paksa lebar A4 (794px @ 96dpi) saat capture agar konten panjang tidak terpotong
    const prevWidth = element.style.width;
    const prevMaxWidth = element.style.maxWidth;
    element.style.width = "794px";
    element.style.maxWidth = "794px";

    // Tunggu semua font selesai dimuat agar tidak berantakan di PDF
    await document.fonts.ready;

    const canvas = await html2canvas(element, {
      scale: 2,
      useCORS: true,
      allowTaint: true,
      width: 794,
      windowWidth: 794,
      onclone: (_doc, clonedElement) => {
        clonedElement.style.fontFamily =
          'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif';
      },
    });

    element.style.width = prevWidth;
    element.style.maxWidth = prevMaxWidth;

    const imgData = canvas.toDataURL("image/png");
    const pdf = new jsPDF("p", "mm", "a4");

    const margin = 12;
    const pageWidth = 210;
    const pageHeight = 297;
    const contentWidth = pageWidth - margin * 2;
    const imgHeight = (canvas.height * contentWidth) / canvas.width;

    let heightLeft = imgHeight;
    let position = margin;

    pdf.addImage(imgData, "PNG", margin, position, contentWidth, imgHeight);
    heightLeft -= pageHeight - margin;

    while (heightLeft > 0) {
      position -= pageHeight - margin;
      pdf.addPage();
      pdf.addImage(imgData, "PNG", margin, position, contentWidth, imgHeight);
      heightLeft -= pageHeight - margin;
    }

    pdf.save(`invoice-${invoice.value.invoice_number}.pdf`);
  } catch (err: unknown) {
    error.value = err instanceof Error ? err.message : "Gagal mengunduh PDF";
  } finally {
    downloading.value = false;
  }
}

function formatDate(date: string) {
  return new Date(date).toLocaleDateString("id-ID", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

function formatCurrency(amount: number) {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
  }).format(amount);
}

onMounted(() => {
  loadInvoice();
});
</script>
